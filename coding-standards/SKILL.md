---
name: coding-standards
description: 'General code and architecture standards for .NET/C# projects. Use when writing or changing C# code, services, or project structure. For front-end/UI-specific standards, use the blazor-frontend skill. For detailed test workflow, use the testing-standards skill.'
argument-hint: 'Code area or architectural change'
---

# Coding Standards

## When to Use

- Write or refactor production C# code.
- Change services, models, or project structure.
- Check whether a change keeps business logic in the right layer.

## Core Rules

- Keep business logic out of UI components and move it into services or other testable types.
- Keep UI components thin; presentation logic is fine, but business rules should live outside the component. (For deeper front-end guidance, use the blazor-frontend skill.)
- Follow the existing C# conventions used in the project: PascalCase for types and members, `_camelCase` private fields, and records for immutable models when that matches the surrounding code.
- Prefer collection expressions over explicit collection constructors and collection initializers when the target type is clear.
- Do not suffix async methods with `Async` unless there is also a non-async version that needs to be distinguished.
- Do not mark classes or records as `sealed`.
- Preserve nullable safety and keep builds warning-free.
- Do not add explicit null guard clauses for non-nullable inputs. Rely on nullable reference types and warnings-as-errors for safety, and let unexpected nulls fail naturally unless null is an intentional supported case.
- Follow the robustness principle for types: accept the most general type that makes sense (interfaces/abstractions) for parameters, but return the most specific concrete type you actually produce. Do not widen return types to an interface when the implementation already knows the concrete type — callers gain nothing from the abstraction and may lose useful information.
- Keep service interfaces limited to real application use cases. Do not expose adapter or factory helpers, pass-through methods, or overloads that exist only because the implementation happens to use them internally.
- Collapse delegating overloads into a single method when the behavior is identical. Prefer optional parameters plus named arguments at call sites over duplicate overloads where one only forwards to the other.
- Default to colocating related types, helpers, and small models with the feature that uses them. Split them into separate files only when the combined code becomes cumbersome to manage or cannot be tested sufficiently while colocated.
- When small records, helper types, or interfaces are colocated with a primary implementation, place those supporting types above the primary class in the file.
- Apply the Single Responsibility Principle: each class, service, and component should have one clear reason to change. A very large file — or a very large test file — is a signal that the code is doing too much and should be split. Look for natural seams: distinct pieces of UI that can become child components, business logic that can move to a service, or groups of tests that belong to a newly extracted unit.
- When a service file accumulates multiple independently testable concerns — such as DTOs, exceptions, prompt builders, parsers, context builders, or mappers — keep them in the same feature folder/namespace but split them into dedicated files so the service file stays focused on orchestration.
- Within a vertical slice (feature area), keep distinct feature concerns in focused sub-slices with their own services instead of expanding a single catch-all service. Introduce shared helpers or shared services only when several sub-slices truly reuse the same logic.
- Keep changes focused and avoid unrelated refactors unless the task requires them.

## Project Structure

- Keep changes consistent with the existing patterns in the main source project and its corresponding test project.
- Check relevant specs under `.specs/` (repo root) before implementing larger features.
- Use the `testing-standards` skill for detailed testing expectations and verification workflow.
