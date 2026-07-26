# Creating Types and Files

Read this **before** creating any new class, interface, record, enum, or `.cs` file.

## The Default: Colocate

A new type does **not** get its own file by default. Put it in the file of the code
that uses it, and split it out only when that file becomes cumbersome to work in or a
type genuinely needs to be tested on its own.

This applies to interfaces, small records and DTOs, option objects, exceptions, enums,
and helper types.

### Supporting types go above the primary class

```csharp
// Processes/ProcessRunner.cs

public interface IProcessRunner
{
    Task<ProcessResult> Run(string fileName, string arguments, CancellationToken cancellationToken);
}

public record ProcessResult(int ExitCode, string StandardOutput, string StandardError);

public class ProcessRunner : IProcessRunner
{
    // ...
}
```

Not this:

```
Processes/IProcessRunner.cs      <- interface alone in a file
Processes/ProcessResult.cs       <- 3-line record alone in a file
Processes/ProcessRunner.cs
```

An `Abstractions/` folder holding one interface per file is the same anti-pattern with
extra directories.

### When to split into a separate file

Split when at least one of these is true:

- The file has grown large enough that finding things in it is a chore.
- The type has its own meaningful behavior and deserves its own test file.
- Several unrelated types in the same feature folder need it.

A service file that has accumulated independently testable concerns — parsers, prompt
builders, mappers, context builders — should keep those in the **same feature folder
and namespace** but move them into dedicated files, so the service file is left doing
orchestration only.

## Where Code Lives

- Application services, repositories, and feature code go in the existing main project.
  Do not add a new class library unless one already exists or the work genuinely
  requires it.
- Organize by **vertical slice**. Look at the existing top-level feature folders and put
  the new type in the one that matches; create a new slice only when the work genuinely
  does not belong to any of them.
- Within a slice, keep distinct concerns in focused sub-slices with their own services
  rather than growing one catch-all service. Add shared helpers only when several
  sub-slices truly reuse the same logic.
- Routed pages, layouts, and other UI components follow the conventions in the UI
  framework's own skill.
- Test files mirror the source path in the test project.

## Type Declaration Rules

- Do **not** mark classes or records as `sealed`.
- Do **not** mark members `internal`.
- Use records for immutable models when that matches the surrounding code.
- Use PascalCase for types and members.

## Splitting a File That Grew Too Large

A very large file — production or test — means the code is doing too much. Look for
natural seams before reaching for an arbitrary split:

- A cohesive group of members that only talk to each other.
- Logic that can move behind its own service or helper.
- A group of tests that belongs to a newly extracted unit.

Split along the seam, not down the middle.

## Self-Check

- [ ] Did every new type go in the smallest reasonable number of files?
- [ ] Is each new file justified by size, testability, or shared use — not habit?
- [ ] Are supporting types placed **above** the primary class in the file?
- [ ] Is the type in the vertical slice that matches the existing folder structure?
- [ ] Nothing marked `sealed` or `internal`?
- [ ] If a test file was added, does its path mirror the source path?
