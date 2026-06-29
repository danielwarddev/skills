# Mutation Testing — Run & Analyze

Assumes the xUnit v2 clone and `stryker-config.json` already exist (see `project-setup.md`).

> **Naming**: `<Project>` is the project under test, `<TestProject>` is its xUnit v3 test project,
> and `<Solution>` is the `.sln`/`.slnx`. Substitute the real repository names.

## 1. Run Stryker

From the **repo root** (reads `stryker-config.json`):

```powershell
dotnet stryker
```

Expect a real split of Killed / Survived / NoCoverage. If you instead see
`test coverage capture failed` and `Killed: 0`, the run is pointed at the xUnit **v3** project —
fix `test-projects` to point at the clone (see `project-setup.md`). A 0-killed report is broken,
not a quality signal; never analyze survivors from it.

## 2. Parse the report

The HTML report embeds the JSON; prefer the `.json` reporter. Summarize survivors with:

```powershell
$r = Get-Content "StrykerOutput\<run>\reports\mutation-report.json" -Raw | ConvertFrom-Json
$s = @{}
foreach ($f in $r.files.PSObject.Properties) {
  foreach ($m in $f.Value.mutants) {
    $s[$m.status] = 1 + $s[$m.status]
    if ($m.status -in 'Survived','NoCoverage') {
      Write-Host ("{0}:{1} [{2}] {3} => {4}" -f (Split-Path $f.Name -Leaf), `
        $m.location.start.line, $m.status, $m.mutatorName, ($m.replacement -replace '\s+',' '))
    }
  }
}
$s.GetEnumerator() | Sort-Object Name | Format-Table -Auto
```

Mutation score = Killed / (Killed + Survived + NoCoverage). ~80%+ on the deterministic core is healthy.

## 3. Report suggestions in importance buckets

Always split survivors into buckets and explain the reasoning — never dump a raw list.

### Triage rubric — classify each survivor in order

A surviving mutant is **not** automatic proof of a missing test. Many are spurious (low-signal):
the mutation describes a change that is either unobservable or not part of the product's actual
behavior. Run each survivor through these questions, in order, and stop at the first match:

1. **Can the mutation change observable behavior at all?** If the mutated code is provably
   equivalent (e.g. clone-of-empty vs `[]`; an operator that's equivalent under an existing
   invariant), it's an **equivalent mutant** → **Bucket 1**. No test can or should kill it.
2. **Is the mutated value something we deliberately don't assert?** Exception message text, log
   strings, and similar side-effect-only arguments → handle via `ignore-methods` in config (see
   `project-setup.md`) → **Bucket 1**. We care about the type/occurrence, not the literal text.
3. **Could the killing scenario actually occur in the system today?** If killing the mutant requires
   a condition the codebase doesn't implement yet — and you'd have to invent a test double to fake
   it (e.g. a strategy/rule variant that production code never instantiates) — **do not fabricate
   it**. It's a **Bucket 4** future-coverage note, not a present gap. This session, we dropped a
   test that introduced a custom rule the production code never uses, for exactly this reason: it
   exercised behavior the system can't currently produce.
4. **Otherwise it's a real gap in behavior the system has today.** Cheap and isolated → **Bucket 2**;
   needs an elaborate multi-element setup → **Bucket 3**.

Guiding principle: a test should pin **behavior the system actually promises**. If a survivor
doesn't map to such behavior, the mutant is overzealous — document why and leave it, rather than
contorting a test to chase the score.

### Buckets

1. **Ignore — equivalent or cosmetic.** Don't write tests for these.
   - Exception **message strings** — handle via `ignore-methods`, not by asserting exact text.
   - **Equivalent mutants**: the mutation can't change observable behavior. Examples: cloning an
     empty collection vs returning an empty literal; a logical operator that is equivalent under an
     existing invariant (e.g. `||`→`&&` on a guard whose two operands can never disagree given an
     upstream invariant). State *why* it's equivalent.

2. **Worth fixing — real, cheap wins.** One small test each.
   - Off-by-one / boundary mutants (`>=`→`>`): assert the boundary value itself (e.g. that index 0
     is in bounds).
   - Uncovered guard branches (`NoCoverage`, or a `return false`→`true` that survives): drive the
     guard (e.g. an empty-collection input that otherwise falls through to a wrong default result).
   - Prefer folding equivalent cases into an existing test as a `[Theory]` over a new method.

3. **Worth a look — real but edge-case.** Flag, estimate effort, implement only if the user agrees.
   - Mutants on ordering-dependent logic (e.g. a sort key that determines processing order):
     construct inputs where the order actually changes the result.

4. **Non-existent conditions — do not fabricate.** A mutant only killable by a condition the
   codebase doesn't implement yet (e.g. a strategy/rule variant production never instantiates).
   Do **not** invent a
   test double to manufacture the scenario — it tests speculative future behavior. Note it as
   coverage that becomes real when that feature lands, and leave the mutant surviving.

## 4. Implement agreed tests, then re-verify

- Write new tests in the **real v3 project** (`<TestProject>\`) — that's their home.
- **Mirror the changed files into the clone**, then re-run `dotnet stryker` to confirm the kills.
- One good test often kills several mutants; re-running shows the true effect.

## 5. Tear down (unless keeping the clone)

- Delete `<TestProject>.XunitV2\` and remove it from the solution.
- Point `stryker-config.json` `test-projects` back at `<TestProject>`; keep the
  `ignore-methods` improvement. `StrykerOutput\` self-ignores via git.

## Verification

- Source v3 suite green: `dotnet test <TestProject>\<TestProject>.csproj`.
- Clone green with matching test count: `dotnet test <TestProject>.XunitV2\...csproj`.
- Solution builds clean (warnings-as-errors): `dotnet build <Solution>`.
- New tests confirmed to kill their target mutants by re-running `dotnet stryker` on the clone.
- After teardown, `git status` shows no `XunitV2` artifacts and the solution still builds.
