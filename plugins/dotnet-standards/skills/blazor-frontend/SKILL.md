---
name: blazor-frontend
description: 'How to use Blazor Server, including front-end patterns, UI states, and component tests. Use when building or changing anything with Blazor - Razor components, forms, loading/empty/error states, bUnit tests, rendering lists, @key, Virtualize, MudBlazor components, or troubleshooting UI behavior/performance. Covers rendering best practices, component granularity, parameter design, bUnit verification, element-component relationships, and which Context7 library IDs to consult for bUnit and MudBlazor docs.'
argument-hint: 'Component, UI state, bUnit test, or rendering scenario'
---

# Blazor Front-End Patterns & Performance

## When to Use

- Building or refactoring Razor components, including forms, buttons, loading states, empty states, and error states.
- Creating a new component and deciding which folder it belongs in.
- Adding component-scoped CSS or JavaScript (`.razor.css`, `.razor.js`).
- Choosing or changing a render mode (`@rendermode`, `[StreamRendering]`).
- Moving business logic out of a component and into a service.
- Adding or reviewing bUnit tests for Razor component rendering, interactions, and async UI state changes.
- Building or refactoring Razor components that render lists, grids, or repeated items.
- Optimizing rendering performance for components that re-render too often.
- Deciding component granularity — when to inline vs. extract child components.
- Using `@key` to preserve element/component identity across re-renders.
- Applying `Virtualize<TItem>` for large scrollable lists.
- Designing component parameters to minimize unnecessary re-renders.
- Using cascading parameters, attribute splatting, or event callbacks at scale.

## Quick Decision Guide

| Situation                                      | Action                                                                                                                                                                        |
|------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Creating a component, or deciding where it goes | See [component architecture reference](./references/component-architecture.md)                                                                                                |
| Component holds business logic or has grown large | Extract a service or child component — see [component architecture reference](./references/component-architecture.md)                                                        |
| Adding component-specific CSS or JS            | Colocate as `.razor.css` / `.razor.js` — see [component architecture reference](./references/component-architecture.md)                                                        |
| Writing or reviewing a bUnit test              | See [bUnit component tests reference](./references/bunit-component-tests.md)                                                                                                  |
| List has < ~50 static items                    | Plain `foreach` loop is fine                                                                                                                                                  |
| List has many items or scrolls                 | Use `Virtualize<TItem>` — see [virtualization reference](./references/rendering-performance.md#virtualization)                                                                |
| Collection items change, insert, or reorder    | Add `@key` on each item — see [key reference](./references/element-key-relationships.md)                                                                                      |
| Child component re-renders but nothing changed | Use immutable parameter types or override `ShouldRender` — see [rendering reference](./references/rendering-performance.md#avoid-unnecessary-rendering-of-component-subtrees) |
| Hundreds or thousands of repeated components   | Consider inlining into parent or using `RenderFragment` — see [rendering reference](./references/rendering-performance.md#avoid-thousands-of-component-instances)             |
| Cascading value never changes after init       | Set `IsFixed="true"` on `CascadingValue`                                                                                                                                      |
| Event handler doesn't change state             | Use `IHandleEvent` or `EventUtil.AsNonRenderingEventHandler`                                                                                                                  |

## Procedure

1. **Identify the scenario** using the decision guide above.
2. **Load the relevant reference** for detailed patterns and code examples:
    - [Component Architecture](./references/component-architecture.md) — where components live, keeping logic out of components, colocated assets, render modes, splitting.
    - [Rendering Performance](./references/rendering-performance.md) — re-render control, virtualization, component weight, parameter design, event handling.
    - [Element & Key Relationships](./references/element-key-relationships.md) — `@key` directive usage, scoping, when to use/avoid, value selection.
    - [bUnit Component Tests](./references/bunit-component-tests.md) — what to assert, what not to test, shared setup.
3. **For bUnit tests**, follow [bUnit Component Tests](./references/bunit-component-tests.md), and query the Context7 MCP server with library ID `/websites/bunit_dev` (canonical bUnit docs) for current patterns — service registration before render, input/click events, `WaitForAssertion` for async renders, JSInterop setup for components that use JavaScript-backed libraries, wrapping the component-under-test with parent providers via a `.razor` host (the test project must use `Microsoft.NET.Sdk.Razor` to compile `.razor` files), etc.
4. **For MudBlazor components**, query the Context7 MCP server with library ID `/mudblazor/mudblazor` for current API usage — dialog/menu/popover patterns, `IMudDialogInstance` (note: methods are `Close` / `Cancel`, not `CloseAsync` / `CancelAsync` in 9.x), `MudPopoverProvider` placement (must be inside the interactive render scope, not a static `MainLayout`), `PositionAtCursor` + `OpenMenuAsync` for context menus, etc.
5. **Apply the pattern** following the code examples in the reference.
6. **Verify** the change builds and all affected tests pass, following the repository's documented build and test commands. For component test rules, see [bUnit Component Tests](./references/bunit-component-tests.md).
7. **REQUIRED: Browser test.** Start the dev server using the repository's documented run command (or `dotnet run` if none is documented), navigate to the affected page, and confirm the UI change looks and behaves correctly with the `#browser` tool, or Playwright MCP if `#browser` is unavailable or insufficient. Keep iterating until it works and looks right. This step is mandatory for every UI change — CSS, markup, and logic alike — and must be completed before reporting the task as done. Include the app URL in your response so the user can open it directly.

## Key Principles

- **Immutable parameters skip re-renders automatically.** Prefer `string`, `int`, `bool`, `DateTime`, and other primitive/immutable types for parameters that don't change often.
- **`@key` is about identity, not performance.** Use it when items get inserted, deleted, or reordered — it tells Blazor *which* element maps to *which* data item.
- **Component granularity is a trade-off.** Each component has ~0.06ms overhead. A few hundred is fine; thousands need inlining or `Virtualize`.
- **Virtualize only renders what's visible.** Requires a fixed-height scroll container and uniform item sizes.
- **Don't optimize prematurely.** Most components don't repeat at scale and don't need aggressive optimization. Focus effort on lists, grids, and high-frequency re-render paths.
