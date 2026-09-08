# Writing C#

Read this when writing or editing method bodies. These rules apply the same way to
new code and to code you are changing: when you touch a method whose name, collections,
or nullability break a rule below, bring it in line as part of that change. That is
in scope, not an unrelated refactor. Leave code you are not otherwise touching alone.

## Naming

- PascalCase for types and members.
- `_camelCase` for private fields.
- Do **not** suffix async methods with `Async` unless a non-async version exists that
  needs to be distinguished from it (**do** use the async modifier in the signature, though).
- Name methods for the specific domain action they perform. Generic verbs such as
  `Read`, `Value`, `Parse`, `Get`, `Required`, `Generate`, `Validate`, `Create`,
  `Process`, or `Handle` are an antipattern when the declaring
  type and parameters do not make the complete behavior obvious at the call site.
  Prefer names such as `ReadOrders`, `GetFieldValue`, `ParseRow`,
  `GetRequiredFieldValue`, `GenerateTheme`, `ValidateTheme`, and `ParseShipDate`.

A method name should let a caller understand its purpose without reading its body. Do
not rely on a narrowly named class alone to compensate for an ambiguous operation name,
especially when several similarly named collaborators form a processing pipeline.

Prefer a clearly named private method over a local function when the code represents a
reusable operation of the class. Local functions should serve genuinely local control
flow or closure needs, not hide ordinary helper logic inside a larger method.

Do not use a helper to silently replace structurally missing positional input with an
empty or default value. When the input contract requires that position, access it
directly and let the boundary fail rather than manufacturing data for later validation.

## Expression Clarity

Do not nest a meaningful method call, `await` expression, or LINQ pipeline inside an
argument list. Assign each operation to a clearly named local, then pass that local to
the next operation. This keeps each transformation visible and makes call sites easier
to read and debug.

```csharp
// Bad
var slug = recipeSlugger.CreateUniqueSlug(
  food.Name,
  (await GetAllFoods(cancellationToken)).Select(existingFood => existingFood.Slug));

// Good
var existingFoods = await GetAllFoods(cancellationToken);
var existingSlugs = existingFoods.Select(food => food.Slug);
var slug = recipeSlugger.CreateUniqueSlug(food.Name, existingSlugs);
```

## External Data Boundaries

Convert positional external data into a named raw model as early as possible. Passing
an array of CSV fields together with a header or index map beyond the CSV adapter is an
antipattern: it leaks transport mechanics into parsing and normalization logic.

Use a two-stage boundary when raw values still require validation or normalization:

```csharp
AmazonOrderCsvRow rawRow = csvMapper.MapRow(fields, rowNumber);
AmazonOrderItem item = itemTransformer.TransformRow(rawRow);
```

The raw record should use meaningful property names and retain source metadata needed
for errors. Downstream services should consume those properties rather than positional
collections or header-name constants.

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

## Async and I/O

Use asynchronous APIs for I/O operations. Propagate `CancellationToken` where
cancellation is meaningful, especially for work tied to a request, operation, or
object lifetime.

## Error Handling

Avoid broad exception catches and silent fallbacks. Do not swallow an exception to
return a default value or keep running in an unknown state.

Surface failures where they are actionable. Catch narrowly, and only when there is a
specific recovery; otherwise preserve the exception or log enough detail to diagnose
the failure.

## Scope

Keep changes focused. Do not fold unrelated refactors, renames, or cleanups into a task
that did not ask for them.

## Self-Check

- [ ] Any `Async` suffix without a non-async counterpart?
- [ ] Any generic method name whose domain action is unclear without reading its body?
- [ ] Did you rename any pre-existing method you touched whose name breaks these rules?
- [ ] Are meaningful calls, `await` expressions, and LINQ pipelines assigned to named
  locals rather than nested inside argument lists?
- [ ] Does positional external data escape its adapter instead of becoming a named raw
      model at the boundary?
- [ ] Any `new List<T>()` / `new T[] { ... }` where a collection expression would work?
- [ ] Any null guards on non-nullable parameters?
- [ ] Do I/O operations use asynchronous APIs and propagate cancellation where it is
  meaningful?
- [ ] Any broad `catch` or silent fallback that hides a failure?
- [ ] Does the build produce zero warnings?
- [ ] Is every changed line actually required by the task?
