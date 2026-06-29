---
name: spec-creation
description: Guidelines for creating feature specification documents. Use this skill when the user asks you to create a new spec or flesh out an existing one, write a user story, or document feature requirements.
---

# Spec Creation

## Overview

This skill defines how to create feature specification documents. Specs are user-story-driven documents with very small numbered implementation sections so the work can be implemented and reviewed one narrow slice at a time.

## File Naming & Location

- **Location**: `.specs/` (repo root)
- **Naming**: `SPEC-XX-Feature-Name.md` (e.g., `SPEC-01-Transaction-Import.md`)
- **Numbering**: Use sequential two-digit numbers (01, 02, 03...)

## Spec Sizing

- Every spec MUST be scoped small enough that the resulting implementation can be manually reviewed in about 5-10 minutes.
- If the work needed for a feature would exceed that review size, it MUST be split into multiple smaller specs instead of being captured in one large spec.
- When splitting, each spec should deliver a coherent slice of value with its own user story, acceptance criteria, and definition of done.
- Use the Out of Scope section to explicitly push overflow work into follow-up specs.
- Even when the work stays in one spec file, that spec MUST still be split into very small numbered implementation sections inside the same file.
- A spec should generally have **AT LEAST** 3–4 implementation sections. Fewer usually means the spec is too small to be standalone or the sections are too coarse and should be split further.
- Do NOT create a separate file for each subsection. Keep one `SPEC-XX-Feature-Name.md` file and place numbered sections like `1.1`, `1.2`, `1.3` inside it.
- Number implementation sections with the spec number as the prefix. For example, Spec 1 uses `1.1`, `1.2`, and `1.3`; Spec 4 uses `4.1`, `4.2`, and `4.3`.
- Keep section numbering shallow. Use `X.Y` only; do not create deeper trees such as `1.2.1`.
- If one numbered section still feels too large to review comfortably, split it into smaller sibling sections or move overflow into a follow-up spec.
- Never include commit, merge, PR, or code-review workflow steps in the spec itself. Specs should stop at implementation and verification; repository history and branch management are handled manually outside the spec.

## Response Format

- When you create or split specs, always include a flat list of the specs you created.
- For each created spec, include a very brief summary of what it covers.
- Keep each summary to one sentence at most.
- Prefer the format: `SPEC-XX-Feature-Name.md: brief summary`.
- When you create or revise a single spec, also include a flat list of the numbered implementation sections you created.
- Prefer the format: `1.1 Section Name: brief summary`.

## Spec Structure

Every spec document MUST include these sections in order:

### 1. Title & Status

```markdown
# Spec X: Feature Name

**Status**: 📋 Not Started | 🚧 In Progress | ✅ Complete

---
```

### 2. User Story

Write from the user's perspective using this format:

```markdown
## User Story

**As a user**, I want to [goal/desire] so that [benefit/reason].
```

### 3. Description

A paragraph or two explaining the feature in more detail. Provide context about why this feature matters and how it fits into the larger application.

### 4. Implementation Sections

This is the most important section. Break the spec into very small numbered sections inside the same file. Each numbered section needs a short description followed by a checkbox list of requirements:

```markdown
## Implementation Sections

Implement this spec one numbered section at a time. Use `SPEC-01.1` for section-scoped execution or `SPEC-01` for the full spec.

### 1.1 [Section Name]

Short paragraph describing the boundary of this section and what it deliberately does not cover yet.

- [ ] Specific, testable requirement
- [ ] Another specific requirement

### 1.2 [Next Section Name]

Short paragraph describing the next narrow slice.

- [ ] More requirements...
```

**Guidelines for implementation sections:**

- Each checkbox is still an acceptance criterion and must be specific and testable
- Use action verbs (User can..., System detects..., Page displays...)
- Avoid vague terms like "should work well" or "is user-friendly"
- Keep each numbered section narrow enough that the resulting implementation stays easy to review in one short pass
- Put the short description immediately under the numbered heading so the purpose of the section is obvious
- Prefer sequential sections that can be implemented in order; add an explicit dependency note only when necessary
- Keep the work in one spec file; numbered sections do not become separate spec files

**Subsection slicing strategy — file-change plan first:**

Before writing implementation sections, you MUST build a **Planned File Changes** list (see spec structure below). Explore the existing codebase to identify every file that will need to be created, modified, or deleted to satisfy the spec's acceptance criteria. Group those file changes into clusters of closely related files — that grouping directly becomes the implementation sections.

This approach prevents subsections from accidentally spanning too many files or layers, because the concrete file list makes the true scope visible before the sections are written.

Process:

1. Read the spec's acceptance criteria and technical notes.
2. Explore the codebase to identify which existing files must change and which new files must be created. List every file with an action: **new**, **modify**, or **delete**.
3. Group files into clusters where each cluster is a small, closely related set — typically one architectural layer and its tests.
4. Each cluster becomes one implementation section. Name the section after the work, not the layer.
5. Validate: if any section's cluster contains more than roughly 8 files or spans 3+ projects, split it further.

Guidelines:

- Always include the corresponding tests for the code in the same section so each section is independently verifiable.
- When a feature requires foundational changes to existing code (e.g., refactoring a base class to support new usage), put those changes in their own section before sections that depend on them.
- If a file appears in multiple clusters (e.g., DI registration touched by service and component sections), assign it to the earliest section that introduces the dependency and note in later sections that it was already modified.

**Common file-cluster patterns:**

- Data models, record types, and entity configuration + their unit tests
- Service or business-logic class + DI registration + service tests
- UI component + styles + component tests (for front-end work, see the blazor-frontend skill)
- Foundational refactors to existing code + updated existing tests
- Integration tests that exercise multiple units together (when not naturally colocated with a single layer)

### 5. Planned File Changes

List every file that will be created, modified, or deleted to implement the spec. This list drives the implementation sections.

```markdown
## Planned File Changes

| Action | File | Section |
|--------|------|---------|
| new    | `Path/To/NewService.cs` | 1.1 |
| new    | `Path/To/Tests/NewServiceTests.cs` | 1.1 |
| modify | `Path/To/ExistingType.cs` | 1.2 |
| new    | `Path/To/Tests/ExistingTypeTests.cs` | 1.2 |
| modify | `Program.cs` | 1.1 |
```

**Guidelines for the file-change plan:**

- Explore the codebase before writing this list; do not guess at file paths.
- Mark each file as **new**, **modify**, or **delete**.
- Assign each file to the implementation section that will make the change.
- If a file is modified in multiple sections, list it in every section where it will be touched so the scope of each section is visible at a glance.
- This list is a plan, not a contract — implementation may discover additional files, and that is fine. Update the list when the spec is revised.

### 6. Out of Scope

Explicitly state what is NOT included in this spec to prevent scope creep:

```markdown
## Out of Scope

- Feature X (will be handled in Spec Y)
- Edge case Z (deferred to future iteration)
```

### 7. Technical Notes

Developer-focused context that helps with implementation:

```markdown
## Technical Notes

- Relevant existing code/projects
- Database considerations
- Integration points
- Performance considerations
```

### 8. UI Wireframe Concepts (Optional)

Include ASCII wireframes **only when helpful** for understanding the UI:

```markdown
## UI Wireframe Concepts

### Page Name

┌─────────────────────────────────────┐
│ Component layout... │
└─────────────────────────────────────┘
```

### 9. Definition of Done

A final checklist that MUST include testing requirements. Reference the coding-standards skill but also include spec-specific items:

```markdown
## Definition of Done

- [ ] All section requirements are met
- [ ] Unit tests cover core logic
- [ ] Integration tests verify data persistence (if applicable)
- [ ] Component/UI tests cover UI interactions (if the project has a UI)
- [ ] If the project has a UI, it has been verified using the `#browser` tool or Playwright MCP, whichever you have
```

## Related Skills

**IMPORTANT**: Always follow the [Coding Standards](../coding-standards/SKILL.md) skill when implementing specs. Tests MUST be written for all features. For front-end work, also use the [blazor-frontend](../blazor-frontend/SKILL.md) skill.

## Example

For a complete example, see an existing spec in the `.specs/` folder at the repo root (e.g. `SPEC-01-<Feature-Name>.md`).
