# Godot Engine Code

Read this **before** writing or changing any code that touches Godot: `Node`-derived
scripts, scenes, input handling, or engine APIs.

## Consult the Engine Docs First

When you need Godot API usage, engine behavior, scene-setup guidance, or
version/migration details, query Context7 first using library ID
`/godotengine/godot-docs`, and treat it as the source of truth before applying any
engine-dependent change. Do not rely on recalled API shapes — Godot's C# API changes
between versions.

When using the Godot MCP server, the project path is the Godot project directory
containing `project.godot`, not the solution root.

## Keep Logic Out of the Engine

This is the central architectural rule.

- **Game logic lives in an engine-free core project** — a plain C# project with no
  Godot reference. State and rules have no `Godot`, `Node`, or scene dependencies, so
  the game can be reasoned about and unit-tested with no engine running. Never add a
  Godot reference or `using Godot;` to that project.
- **The Godot layer only renders state and relays input.** Keep `Node` scripts thin:
  read input, call into the core, and draw or tween the resulting state. The view
  observes the model and never owns rules.
- Move substantial behavior out of engine callbacks such as `_Ready`, `_Process`, and
  `_PhysicsProcess` into clearly named methods or core services. The callback should
  read as a short sequence of calls.
- Prefer determinism and testability over micro-optimization in the core. Game
  decisions such as wave and spawn choreography, formation assignment, state
  transitions, and hit resolution belong in deterministic core logic. Positional
  interpolation itself, such as tweening between two points or following a `Path2D`,
  can use Godot's `Tween`, `Path2D`, and `PathFollow2D` directly in the node script.
  Do not reimplement and unit-test reliable engine features solely to keep their math
  in the core. Use core-side movement math when a pattern is driven by data the core
  already owns or must be queried deterministically outside one node's lifecycle.
- Do not put credentials, API keys, or tokens in source, scenes, resources, or
  `project.godot`.

## Node Scripts and Wiring

- **Always use `[Export]` to wire child or sibling node references.** Use `GetNode` only
  for lookups that genuinely must happen at runtime, never for startup wiring. Name-based
  `GetNode` wiring is brittle and breaks silently when a node is renamed.
- This applies to ancestor references too. Prefer an exported ancestor reference wired
  by the scene over resolving it in `_Ready` with fixed-depth `GetParent` chains. The
  scene-authored reference survives hierarchy changes that would break those chains.
- **Exported members are always `private`.** An exported value is the node's own
  configuration and should not be writable by another class. When another class must
  read one, keep the exported field private and expose a get-only property.

  ```csharp
  // Good
  [Export] private float _speed = 400.0f;
  [Export] private PackedScene _bulletScene;

  public float Speed => _speed;

  // Bad — public export, writable by anyone
  [Export] public float Speed = 400.0f;
  ```

- **The exported member's C# name is the key stored in the `.tscn`.** Renaming an
  exported member also renames the scene property. Rename exports through the editor,
  or update every `.tscn` assignment and run the project to confirm the value arrived.
- An exported `Node` reference is resolved only when the `.tscn` node header declares
  it in `node_paths=PackedStringArray(...)` alongside the `NodePath` assignment. The
  editor writes both. When hand-editing a scene, preserve both parts and run the project
  to confirm the reference resolved.
- Prefer small, focused `Node` components injected via `[Export]` into the node that
  coordinates them, rather than one large script that does everything.
- Use exported properties and scene composition for designer-configurable values instead
  of hard-coded constants or node-path lookups.
- Apply Single Responsibility to `Node` scripts: one clear reason to change. A large
  script is a signal to extract a rule into the core or split off a sub-scene with its
  own node.
- Prefer C# events (`event Action` / `event Action<T>`) over Godot signals for
  communication between C# objects. Reserve Godot signals for editor-visible or
  scene-tree-driven hookups where a signal is genuinely required.
- Where a physics body is driven by components, keep per-frame integration in
  `_PhysicsProcess` and mutate velocity through the component's methods rather than
  writing to it from several places.
- Pool frequently spawned nodes instead of instantiating and freeing them for every
  use. Let a pooled node signal the end of its own lifecycle rather than making every
  caller responsible for returning it.
- **Do not null-check `[Export]` fields, and do not use `GetParentOrNull` or
  `GetNodeOrNull` for wiring resolved once in `_Ready`.** An export is required scene
  configuration that the editor guarantees will be assigned. If it is null, the scene
  is misconfigured and should fail loudly rather than be silently tolerated. Likewise,
  use non-`OrNull` accessors for required ancestor or child lookups in a fixed scene
  hierarchy. Use `OrNull` variants only when a reference is genuinely optional at
  runtime.

## Input

- Use the input actions declared in `project.godot`. Add new actions there rather than
  hard-coding keys or scancodes in scripts.
- Treat input action names, node paths, resource paths, and scene names as contracts:
  when one changes, update every reference to it.

## Scenes, Resources, and Threading

- Prefer editing scenes and project settings through Godot-aware tooling or the editor.
  If a text edit to a `.tscn`, `.tres`, or `project.godot` file is necessary, preserve
  the existing format and verify the project still loads afterward.
- Preserve user-authored scene and resource changes. Make a focused edit rather than
  regenerating or replacing a scene wholesale.
- A new `.cs` script gets a `.uid` file generated by Godot on import. Let the editor
  create it, then reference the generated `uid://` value from scenes rather than
  inventing one.
- Reference project assets with `res://` paths, and add new files to the correct project.
- Never edit generated artifacts under `.godot/`, `bin/`, or `obj/`, and keep them out of
  commits along with local editor state.
- Follow Godot's threading rules: touch nodes and the scene tree only from valid engine
  contexts, and never block the main thread with network or other long-running work.
  Use async APIs and propagate a `CancellationToken` tied to the node or scene lifetime.

## Testing Engine Code

- Engine-free core logic is tested in the core test project. Put reusable logic there
  specifically so it can be tested without launching Godot.
- Godot-facing changes — scenes, input, node lifecycle, rendering — also require running
  the project and exercising the affected flow, then checking the debugger output for
  script, resource, and scene errors.
- Do not widen a member's visibility to make a `Node` script testable. Extract the logic
  into the core instead.

## Self-Check

- [ ] Did you consult `/godotengine/godot-docs` via Context7 for any engine-dependent
      behavior?
- [ ] Is the core project still free of Godot references?
- [ ] Are `Node` scripts limited to input, wiring, and rendering, with rules in the core?
- [ ] Are all child/sibling node references wired with `[Export]` rather than `GetNode`?
- [ ] Are required ancestor references exported instead of resolved through fixed-depth
  parent chains?
- [ ] Is every `[Export]` member private, with a get-only property only when needed?
- [ ] Do hand-edited `.tscn` node references include their `node_paths` declarations?
- [ ] Do all `.tscn` assignments match the exported members' current C# names?
- [ ] Are required exports and fixed-hierarchy lookups left unchecked for null so
  misconfiguration fails loudly?
- [ ] Are C# events used for internal communication, with signals reserved for
      editor/scene-tree hookups?
- [ ] Are new input bindings declared as actions in `project.godot`?
- [ ] Do all renamed node paths, actions, scenes, and resources have every reference
      updated?
- [ ] Is engine work off the main thread where it could block, with cancellation
      propagated?
- [ ] Was the project run in Godot for scene, input, lifecycle, or rendering changes?
