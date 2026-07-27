# Writing C#

Read this when writing or editing method bodies.

## Naming

- PascalCase for types and members.
- `_camelCase` for private fields.
- Do **not** suffix async methods with `Async` unless a non-async version exists that
  needs to be distinguished from it (**do** use the async modifier in the signature, though).

```csharp
// Good — there is no synchronous counterpart
public async Task<Document> Import(string url);
```

## Collections

Prefer collection expressions over explicit constructors and initializers when the
target type is clear.

```csharp
// Good
List<string> steps = [];
string[] arguments = ["--output", path];

// Bad
var steps = new List<string>();
var arguments = new string[] { "--output", path };
```

## Nullability

- Preserve nullable safety and keep builds warning-free.
- Do **not** add explicit null guard clauses for non-nullable inputs.

```csharp
// Bad — the compiler already enforces this
public Document Parse(string markdown)
{
    ArgumentNullException.ThrowIfNull(markdown);
    ...
}
```

Rely on nullable reference types and warnings-as-errors, and let an unexpected null
fail naturally. Add an explicit check only when null is an intentional, supported case
with its own behavior.

## Scope

Keep changes focused. Do not fold unrelated refactors, renames, or cleanups into a task
that did not ask for them.

## Self-Check

- [ ] Any `Async` suffix without a non-async counterpart?
- [ ] Any `new List<T>()` / `new T[] { ... }` where a collection expression would work?
- [ ] Any null guards on non-nullable parameters?
- [ ] Does the build produce zero warnings?
- [ ] Is every changed line actually required by the task?
