# Creating and Editing Types and Files

Read this **before** creating or editing any class, interface, record, enum, or `.cs`
file. These rules apply the same way to new code and to code you are changing.

## The Default: Colocate

A type does **not** get its own file by default. Put it in the file of the code
that uses it, and split it out only when that file becomes cumbersome to work in or a
type genuinely needs to be tested on its own.

This applies to interfaces, small records and DTOs, option objects, exceptions, enums,
and helper types.

### Existing files count too

When you edit a type and its supporting types are sitting in their own files against
this rule, merge them into the file of the code that uses them as part of that change.
Bringing layout in line with this standard is **in scope**, not an unrelated refactor —
"keep changes focused" does not exempt files you are already modifying. Leave files you
are not otherwise touching alone.

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

### Private helper count is a design signal

Needing more than one or two private methods in a class is a code smell. It often means
the class contains multiple responsibilities whose boundaries are being hidden behind
private helpers. Before adding another private method:

- Identify whether the helper belongs to a cohesive concern such as parsing, mapping,
  validation, formatting, or persistence.
- Extract that concern into a focused service or collaborator when it has meaningful
  behavior of its own.
- Keep the original class responsible for orchestration rather than implementation
  details spread across many private methods.

This is a design signal, not a mechanical prohibition: a second small helper may remain
when extraction would make the code less cohesive. The default response to a growing
private-method count should still be to re-evaluate responsibilities, not to keep
accumulating helpers.

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

### Do not blank-line-separate single-line members

Consecutive single-line members — interface method declarations, fields, constants, and
auto-properties — are grouped with no blank line between them. Blank lines separate
members that have bodies, or genuinely distinct groups, not every declaration.

```csharp
// Good
public interface IProcessRunner
{
    Task Initialize(CancellationToken cancellationToken = default);
    Task<ProcessResult> Run(string fileName, CancellationToken cancellationToken = default);
}

// Bad
public interface IProcessRunner
{
    Task Initialize(CancellationToken cancellationToken = default);

    Task<ProcessResult> Run(string fileName, CancellationToken cancellationToken = default);
}
```

## Splitting a File That Grew Too Large

A very large file — production or test — means the code is doing too much. Look for
natural seams before reaching for an arbitrary split:

- A cohesive group of members that only talk to each other.
- Logic that can move behind its own service or helper.
- A group of tests that belongs to a newly extracted unit.

Split along the seam, not down the middle.

## Self-Check

- [ ] Did every type you created or edited go in the smallest reasonable number of files?
- [ ] Is each file justified by size, testability, or shared use — not habit?
- [ ] Did you merge any single-type files belonging to code you edited in this change?
- [ ] Are supporting types placed **above** the primary class in the file?
- [ ] Is the type in the vertical slice that matches the existing folder structure?
- [ ] Nothing marked `sealed` or `internal`, including types that already had those
      modifiers before your change?
- [ ] Are consecutive single-line members grouped without blank lines between them?
- [ ] If a test file was added, does its path mirror the source path?
- [ ] Does any class have more than one or two private methods, and if so, were its
      responsibilities re-evaluated and cohesive logic extracted?
