# Deterministic Enforcement Audit — `csharp-standards`

_Analysis of which rules in the `csharp-standards` skill could be enforced mechanically
(analyzers, formatters, architecture tests) instead of as prose the model must remember._

## Summary

Roughly **half the rules are mechanically checkable**. The highest-leverage move is a
shipped `.editorconfig` + `Directory.Build.props` + `BannedSymbols.txt` template, which
covers a large share with **zero custom code**. A small custom analyzer package covers
most of the rest. Anything moved to the build can be *deleted* from the markdown —
shrinking the context the model has to hold.

Critical prerequisite: `<EnforceCodeStyleInBuild>true</EnforceCodeStyleInBuild>` —
without it `IDE*` rules never run at build time, only in the IDE.

---

## Tier 1 — Free today, config only

| Rule (source) | Mechanism |
|---|---|
| PascalCase types/members; `_camelCase` private fields (`writing-csharp`, `creating-and-editing-types`) | `.editorconfig` naming rules → `IDE1006` severity `error` |
| Collection expressions over `new List<T>()` / `new T[]{}` (`writing-csharp`, `writing-tests`) | `IDE0028` / `IDE0300` / `IDE0301` / `IDE0305` = `error` |
| Explicit types, not `var` (implied by every example) | `csharp_style_var_* = false:error` (`IDE0007`/`IDE0008`) |
| "Build produces zero warnings" (self-check, x2) | `TreatWarningsAsErrors=true` + `Nullable=enable` in `Directory.Build.props` |
| Vertical-slice namespace/folder alignment (`creating-and-editing-types`) | `IDE0130` = `error` |
| Never SQLite/EF InMemory in DB tests (`persistence`) | `Microsoft.CodeAnalysis.BannedApiAnalyzers` → ban `UseInMemoryDatabase`, `UseSqlite`; plus MSBuild package ban |
| Never call external services from a test (`writing-tests`) | BannedApiAnalyzers on `HttpClient` ctor / `HttpMessageInvoker` in test projects |
| AwesomeAssertions/NSubstitute, not FluentAssertions/Moq (`writing-tests`) | Banned package/namespace rules |
| Test naming shape `When_*_Then_*` (`writing-tests`) | xUnit analyzers won't do it, but an `.editorconfig` naming rule with a symbol spec gets the prefix / `_Then_` part |

### Analyzers you must explicitly *disable*

This is a genuine risk: adopting Roslynator/CA wholesale without an opt-out list will
produce guidance that **contradicts the skill**.

- `CA1852` (seal internal types) — you forbid `sealed`
- `RCS1046` (add `Async` suffix) — you forbid it
- `CA1062` (validate arguments non-null) — you forbid null guards
- `RCS1187` / `RCS1085`-style "use `var`" opinions

---

## Tier 2 — Small custom analyzer, high confidence

Pure syntax checks, each roughly 30–60 lines. One shared analyzer project, shipped as a
NuGet package or `ProjectReference`.

1. **No `sealed`, no `internal`** (`creating-and-editing-types`) — trivial modifier
   check. Currently a self-check item the model routinely forgets on pre-existing code;
   the single best custom-analyzer candidate.
2. **No `Async` suffix without a non-async sibling** (`writing-csharp`) — symbol action:
   name ends in `Async`, containing type lacks the same name minus suffix → error. Fully
   decidable.
3. **No `ArgumentNullException.ThrowIfNull(x)` where `x` is a non-nullable reference
   param** (`writing-csharp`) — decidable from nullable annotations.
4. **No blank line between consecutive single-line members**
   (`creating-and-editing-types`) — trivia check. Note: **CSharpier will not do this.**
   It preserves author blank lines between members, so this rule needs the analyzer
   regardless of whether CSharpier is adopted.
5. **`Received()` / `DidNotReceive()` in tests** (`writing-tests`) — ban as a *warning*
   with documented suppression, since the rule has a legitimate exception.
6. **NSubstitute sequential `Returns(first, [])`** with a bare collection expression
   (`writing-tests`) — a real footgun, precisely detectable, and exactly the kind of bug
   a human won't catch in review.
7. **`GetNode` inside `_Ready`** (`godot-engine-code`) — heuristic but tight: startup
   wiring is what `_Ready` is for. Warning severity.
8. **Private method count > 2** (`creating-and-editing-types`) — decidable, but framed in
   the skill as "a design signal, not a mechanical prohibition." Ship at
   `suggestion`/`warning`, never `error`, or it inverts the rule's intent.

---

## Tier 3 — Convention/architecture tests (`dotnet test` failure)

ArchUnitNET or NetArchTest, or in several cases plain xUnit. These fail the *test* run
rather than the build, which is still deterministic AI feedback.

1. **Core project has no Godot dependency** (`godot-engine-code`) — the flagship arch
   rule. Assert `typeof(CoreMarker).Assembly.GetReferencedAssemblies()` contains no
   `GodotSharp`. Stronger and faster than an ArchUnit type-dependency rule.
2. **All EF keys are `int`, never `Guid`** (`persistence`) — inspect `DbContext.Model`,
   assert every key property is `int`. Clean, total, no heuristics.
3. **Test file paths mirror source paths** (`writing-tests`) — filesystem walk or
   `[CallerFilePath]` convention test.
4. **DI graph resolves** (`designing-service-apis`) — build the real `ServiceProvider`
   and validate every registered service constructs. Notable because it *replaces*
   something the skill currently bans: it gives registration safety without per-service
   registration tests, strengthening the "don't test wiring" rule rather than
   contradicting it.
5. **Slice isolation** — ArchUnitNET can assert feature slices don't reference each
   other's internals. Not currently a stated rule; add only if actually wanted.

---

## Tier 4 — Leave in the skill (genuinely judgment)

Don't automate these; attempts will produce false positives that erode trust in the
whole rule set.

- Colocate-by-default vs. split-into-file; "file grew cumbersome"; "split along the seam"
- Domain-specific method naming (`Read` → `ReadOrders`) — semantic, not syntactic
- Robustness principle for signatures (return concrete, accept general) — needs intent
- "Interface members map to real use cases"; collapsing delegating overloads
- Two-stage external data boundary / raw named models
- What not to test (delegation, framework defaults)
- AAA blank-line rules — dependent on "section grew past one line," and CSharpier won't
  touch intra-method blank lines
- Godot: keeping logic out of engine callbacks, `[Export]` vs `GetNode` in general,
  events vs signals as a default

---

## CSharpier specifically

Smaller win than expected. It normalizes brace/indent/wrapping — none of which the skill
actually legislates. The one formatting-shaped rule (blank lines between single-line
members) is outside its scope. Adopt it for churn reduction if desired, but it retires
**zero** rules from the markdown.

---

## Portability caveat

These skills are built to be drop-in portable (see the `skill-portability-audit` skill in
this repo). Analyzers and arch tests are inherently per-repo infrastructure.

The clean resolution: ship a `csharp-standards/assets/` folder containing
`.editorconfig`, `Directory.Build.props`, `BannedSymbols.txt`, and an arch-test template,
with the skill instructing:

> If this repo lacks these, install them from `assets/`. The rules they enforce are then
> omitted from this document.

That keeps the skill portable while letting the enforced rules leave the prompt.

---

## Recommended order

1. `Directory.Build.props` (`TreatWarningsAsErrors`, `EnforceCodeStyleInBuild`,
   `Nullable`) + `.editorconfig` — largest win, one afternoon.
2. `BannedSymbols.txt` — kills the InMemory/SQLite and external-service rules outright.
3. Analyzer opt-out list — do this *with* step 1, or the tooling will actively contradict
   the skill.
4. Custom analyzer for Tier 2 items 1–4.
5. Arch/convention tests for Tier 3 items 1, 2, and 4.

Rules retired from the markdown after all five: roughly **15–18 of ~60**, concentrated in
the self-check lists — precisely where the model currently spends attention re-verifying
things a compiler could have answered.
