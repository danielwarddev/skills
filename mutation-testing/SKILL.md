---
name: mutation-testing
description: 'Use when running mutation testing (Stryker.NET) on a .NET project, or when asked to measure/improve test effectiveness beyond line coverage. Handles the xUnit v3 / .NET 10 Stryker incompatibility by building a temporary xUnit v2 clone, runs Stryker, and reports prioritized suggestions.'
argument-hint: 'Project to mutate (defaults to the project under test) or a survivor to address'
---

# Mutation Testing

## When to Use

- Asked to run a mutation report, measure mutation score, or check whether the tests
  actually catch regressions (not just line coverage).
- Asked to analyze an existing `StrykerOutput/.../reports/mutation-report.html` (or `.json`).
- Hardening a project's test quality before a release or a tricky refactor.

## Background: why a v2 clone is needed

Stryker.NET's default `vstest` runner can't capture results from **xUnit v3** projects — they run on Microsoft.Testing.Platform, which Stryker doesn't yet support.
The symptom is a run where the initial test count is correct but **every mutant "survives"**:

```
[ERR] It looks like the test coverage capture failed. Disable coverage based optimisation.
Killed: 0   Survived: <all>
```

A report with **0 killed despite a green test suite is a broken run, not a quality signal** —
don't start "fixing" survivors from it. The workaround is to mutation-test a byte-for-byte
**xUnit v2** clone of the test project (`<Name>.XunitV2`); xUnit v2 is pure VSTest, and the
core test sources almost never use v3-only APIs, so the clone needs only a csproj package swap.

> Future simplification: once Stryker's MTP runner (`"test-runner": "mtp"`, currently preview)
> or native v3 support stabilizes, the clone may become unnecessary — re-check before cloning.

## Workflow (progressive disclosure)

Read the relevant reference when you reach that phase, rather than loading both up front:

1. **Set up the clone + config** — first run, or after a teardown. Installs the tool, creates the
   `<TestProject>.XunitV2` clone (where `<TestProject>` is the test project for the code under
   test), swaps the xUnit packages, and writes `stryker-config.json`.
   → **`references/project-setup.md`**

2. **Run Stryker, analyze, and report** — runs `dotnet stryker`, parses the report, presents
   prioritized suggestions, implements agreed tests in the real v3 project (mirrored to the clone),
   and tears down.
   → **`references/run-and-analyze.md`**

If the clone and config already exist, skip straight to step 2.

## Key rules (don't violate)

- **0 killed = broken run.** Verify the config points `test-projects` at the `.XunitV2` clone,
  not the xUnit v3 project, before trusting any numbers.
- **New tests live in the real v3 project** (the actual test project, e.g. `<TestProject>\`); mirror
  them into the clone only to re-verify kills.
- **`ignore-methods` uses the `.ctor` suffix** (e.g. `"*Exception.ctor"`), not `.constructor` —
  the wrong suffix silently does nothing.
- **Don't fabricate test doubles** to kill a mutant that only a condition the codebase doesn't
  implement yet could exercise; report it as future coverage and leave it surviving.
- **A surviving mutant isn't automatically a missing test.** Many are spurious — equivalent, or
  describing behavior the product doesn't have. Use the triage rubric in `run-and-analyze.md`
  before proposing any new test.
- Always present survivors in **importance buckets** with reasoning — never a raw list.
