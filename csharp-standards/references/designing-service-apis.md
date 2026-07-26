# Designing Service APIs

Read this before adding a service, changing a public signature, or deciding what an
interface should expose.

## The Robustness Principle for Signatures

**Accept the most general type that makes sense; return the most specific type you
actually produce.**

```csharp
// Good: takes an abstraction, returns what it really builds
public List<Order> Filter(IEnumerable<Order> orders, string term)
```

```csharp
// Bad: return type widened for no reason — callers lose Count, indexing, and mutability
public IEnumerable<Order> Filter(IEnumerable<Order> orders, string term)
```

Do not widen a return type to an interface when the implementation already knows the
concrete type. Callers gain nothing from the abstraction and lose useful information.

## Keep Interfaces to Real Use Cases

An interface describes what the *application* needs, not what the implementation
happens to do internally.

Do not expose:

- Adapter or factory helpers that exist to serve the implementation.
- Pass-through methods that only forward to another member.
- Overloads that exist because one internal call site found them convenient.

## Collapse Delegating Overloads

If two overloads have identical behavior and one only forwards to the other, keep one
method with an optional parameter and use named arguments at the call sites.

```csharp
// Good
public Task<Document> Import(string url, IProgress<ImportStep>? progress = null);

// Bad
public Task<Document> Import(string url);
public Task<Document> Import(string url, IProgress<ImportStep> progress);
```

## Registration

`Program.cs` is the composition root and the place to register new services, SDK
wrappers, and HTTP pipeline behavior. When a slice needs several related registrations,
follow the existing pattern of a slice-local `ServiceCollectionExtensions` method and
call it from `Program.cs`.

Do not write tests that only assert a service was registered — see
[writing-tests.md](./writing-tests.md).

## Self-Check

- [ ] Do parameters accept the most general type that makes sense?
- [ ] Do return types expose the concrete type actually produced?
- [ ] Does every interface member correspond to a real application use case?
- [ ] Are there delegating overloads that should collapse into one method?
- [ ] Are new services registered in `Program.cs` (directly or via a slice extension)?
