---
name: csharp-standards
description: 'C# and .NET standards. Use when adding or editing a class, interface, record, or enum; adding or editing any .cs file; designing a service or its public API; writing or changing any production C# code; writing Godot Node scripts, scene wiring, or input handling; adding persistence, entities, or EF migrations; or writing, reviewing, or fixing unit and integration tests. Routes to focused references for each of those tasks. Excludes UI and markup concerns, which belong to the UI framework skill.'
argument-hint: 'The C# task you are about to start'
---

# C# Standards

This file is a router. It contains no rules of its own — find your task below and
**read the linked reference before you write code**.

## Routing

| You are about to... | Read |
|---|---|
| Create **or edit** a class, interface, record, enum, or delegate | [creating-and-editing-types.md](./references/creating-and-editing-types.md) |
| Add a new `.cs` file, edit an existing one, or decide where code should live | [creating-and-editing-types.md](./references/creating-and-editing-types.md) |
| Split a file that has grown too large | [creating-and-editing-types.md](./references/creating-and-editing-types.md) |
| Design or change a service's public API, method signatures, or return types | [designing-service-apis.md](./references/designing-service-apis.md) |
| Register a service, or decide what belongs behind an interface | [designing-service-apis.md](./references/designing-service-apis.md) |
| Write or edit method bodies — naming, collections, nullability, async | [writing-csharp.md](./references/writing-csharp.md) |
| Add an entity, key, query, or EF migration | [persistence.md](./references/persistence.md) |
| Write or change a `Node` script, scene wiring, input handling, or any Godot API usage | [godot-engine-code.md](./references/godot-engine-code.md) |
| Decide whether logic belongs in the engine-free core or the Godot layer | [godot-engine-code.md](./references/godot-engine-code.md) |
| Write or review a unit or integration test | [writing-tests.md](./references/writing-tests.md) |
| Decide whether something needs a test at all | [writing-tests.md](./references/writing-tests.md) |

This skill covers C# only. UI and framework-specific concerns — markup, components,
styling, rendering, and component tests — belong to that framework's own skill.

## Procedure

1. Identify what you are about to do and open the matching reference(s) above. More
   than one usually applies — adding a tested service touches several.
2. Apply the rules as you write, not as a review pass afterward.
3. Run the self-check at the bottom of each reference you opened.
4. Verify with the repository's documented build and test commands, or `dotnet build`
    and `dotnet test` if none are documented. If a build or test fails because of your
   change, keep making focused fixes and re-running until it passes. Do not report the
   work as done while change-related build or test failures remain.

## Cross-Cutting Principles

These inform every reference, which is why they live here rather than in one of them.

- **Single Responsibility.** Each class, service, and test file should have
  one clear reason to change. A very large file is a signal that it is doing too much.
- **Colocate by default, split on friction.** Keep related code together until the
  combined file becomes cumbersome or untestable — then split along a real seam.
- **Keep changes focused.** Do not fold unrelated refactors into a task.
