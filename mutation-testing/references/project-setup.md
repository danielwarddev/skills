# Mutation Testing — Project Setup

Everything needed to get a runnable Stryker setup: the xUnit v2 clone and the config.
Do this once; reuse the clone on later runs (recreate only if it was torn down).

> **Naming**: This guide uses placeholders — `<Project>` is the project under test (e.g. a core
> library), `<TestProject>` is its xUnit v3 test project, and `<Solution>` is the `.sln`/`.slnx`.
> Detect the real names from the repository (the project under test and the test project that
> mirrors it) and substitute them throughout.

## 1. Ensure the tool is installed

```powershell
dotnet stryker --version   # if missing:
dotnet tool install --global dotnet-stryker
```

**Require 4.16.0 or newer on .NET 10.** Older versions (4.15 and below) ship a Roslyn that can't
load `Microsoft.CodeAnalysis.Razor.Compiler` (`ReferencesNewerCompiler`), so Razor-generated types
like `App` disappear and the mutated assembly fails to compile — the run dies with
`Internal error due to compile error` before testing anything. `dotnet tool update --global
dotnet-stryker` fixes it.

## 2. Confirm the source test suite is green

```powershell
dotnet test <TestProject>\<TestProject>.csproj
```

A clone of broken tests is useless — fix failures first.

## 3. Scan the v3 tests for v3-only APIs

Almost always none. Grep the test sources for `TestContext`, `Assert.Multiple`,
`ITestOutputHelper`, `IAsyncLifetime`, or other v3-specific usage. If any exist, port them to the
v2 equivalent in the clone; otherwise the sources copy verbatim.

**In this repo, two ports are needed** — apply them to the clone only, never to the v3 sources:

1. `TestContext.Current.CancellationToken` is used throughout and doesn't exist in v2. Add
   `XunitV2TestContextShim.cs` to the clone rather than editing ~90 call sites:

   ```csharp
   namespace Xunit;

   public static class TestContext
   {
       public static TestContextShim Current { get; } = new();

       public sealed class TestContextShim
       {
           public CancellationToken CancellationToken => CancellationToken.None;
       }
   }
   ```

2. `ComponentTestContext : BunitContext` fails all 25 bUnit tests under v2 with
   `'MudBlazor.KeyInterceptorService' type only implements IAsyncDisposable`. xUnit v3 disposes
   the context asynchronously; v2 calls only `IDisposable.Dispose`. In the clone, add
   `IAsyncLifetime` so the async path runs first:

   ```csharp
   public class ComponentTestContext : BunitContext, IAsyncLifetime
   {
       Task IAsyncLifetime.InitializeAsync() => Task.CompletedTask;

       async Task IAsyncLifetime.DisposeAsync() => await ((IAsyncDisposable)this).DisposeAsync();
   ```

`bunit` 2.x is test-framework agnostic, so it needs no package change.

## 4. Create the clone `<TestProject>.XunitV2` (if it doesn't exist)

- New folder `<TestProject>.XunitV2\`, preserving subfolders.
- Copy every `.cs` (and `.gdignore`) from `<TestProject>\` **except** the `.csproj`,
  `bin\`, and `obj\`. Keep namespaces unchanged (the original test namespace) — it's a separate
  assembly, so there's no collision.

```powershell
$src = "<TestProject>"; $dst = "<TestProject>.XunitV2"
New-Item -ItemType Directory -Force -Path $dst | Out-Null
Get-ChildItem -Recurse $src -File |
  Where-Object { $_.FullName -notmatch '\\(bin|obj)\\' -and $_.Extension -ne '.csproj' } |
  ForEach-Object {
    $rel = $_.FullName.Substring((Resolve-Path $src).Path.Length + 1)
    $target = Join-Path $dst $rel
    New-Item -ItemType Directory -Force -Path (Split-Path $target) | Out-Null
    Copy-Item $_.FullName $target -Force
  }
```

- Add `<TestProject>.XunitV2.csproj` (see "v2 csproj" below), then:

```powershell
dotnet sln <Solution> add <TestProject>.XunitV2\<TestProject>.XunitV2.csproj
```

## 5. Verify the clone is green and VSTest-based

```powershell
dotnet test <TestProject>.XunitV2\<TestProject>.XunitV2.csproj
```

The line `A total of 1 test files matched the specified pattern` confirms VSTest (good).
The test count must match the v3 project.

> Note: in this repo the v3 project also prints `A total of 1 test files matched the specified
> pattern` (it references `xunit.runner.visualstudio`), so that line does **not** prove you're on
> the clone. The only reliable check is the Stryker run itself: 0 killed means you're still on v3.

> `dotnet sln <Solution> remove` rewrites `.slnx` and drops existing `DisplayName` attributes.
> After teardown, check `git diff <Solution>` and `git checkout -- <Solution>` if it changed.

> **The clone directory is gitignored** (`*.XunitV2/` in `.gitignore`), but the clone still has to
> be listed in `<Solution>` — dropping it makes Stryker fall back to the v3 project and report
> `Killed: 0`. That means the `<Solution>` edit is **local-only: never commit it**, or the solution
> will point at a directory nobody else has. Revert it with `git checkout -- <Solution>` at
> teardown, and keep it out of any commit made while the clone exists.

## v2 csproj

Copy the v3 `.csproj` and change **only** the xUnit packages — keep `TargetFramework` (`net10.0`),
`Microsoft.NET.Test.Sdk`, and any AutoFixture / AwesomeAssertions / NSubstitute / coverlet refs:

```xml
<!-- replace the xunit.v3 PackageReference with: -->
<PackageReference Include="xunit" Version="2.9.3" />
<PackageReference Include="xunit.runner.visualstudio" Version="3.1.5">
  <IncludeAssets>runtime; build; native; contentfiles; analyzers; buildtransitive</IncludeAssets>
  <PrivateAssets>all</PrivateAssets>
</PackageReference>
```

Keep `<Using Include="Xunit" />` — the `Xunit` namespace exists in both versions, so `[Fact]`,
`[Theory]`, `Assert`, etc. compile unchanged.

## stryker-config.json (repo root)

```json
{
  "stryker-config": {
    "solution": "<Solution>",
    "project": "<Project>.csproj",
    "test-projects": [
      "<TestProject>.XunitV2/<TestProject>.XunitV2.csproj"
    ],
    "mutate": [
      "!**/Program.cs"
    ],
    "ignore-methods": [
      "*Exception.ctor"
    ],
    "reporters": ["html", "progress", "json"],
    "thresholds": { "high": 80, "low": 60, "break": 0 }
  }
}
```

- `project` is the **file name** of the project under test (not a path).
- `mutate` with a `!` prefix excludes files. `Program.cs` is the Blazor composition root — its
  mutants are unkillable noise (43 survivors here), so it's excluded.
- `ignore-methods` skips mutations of a call's **arguments**. The suffix is **`.ctor`**, not
  `.constructor` — the wrong suffix silently does nothing.

### When to add something to `ignore-methods`

Add a method/constructor here when you care that **the call happens (and its type/identity)**,
not about the **literal argument values**. Mutating those args produces survivors that no
reasonable test should pin, because the value isn't part of the behavioral contract.

- `*Exception.ctor` — we assert the **exception type** (and that it's thrown), never the exact
  message wording. Added this session for exactly that reason.
- Logging / diagnostics — e.g. `*Log`, `*LogInformation`, `Console.Write*`. Log text is not a
  behavioral contract; don't make tests assert it.
- Pure plumbing whose args don't change observable behavior — e.g. `ConfigureAwait`.

Do **not** ignore a method whose argument values *are* behaviorally significant (e.g. a domain
call like `account.Withdraw(amount)` or `Math.Clamp(value, min, max)`) — those mutants are real and
a test should catch them. When unsure, prefer fixing the test over widening `ignore-methods`.

Next: see `run-and-analyze.md` to run Stryker and interpret the report.
