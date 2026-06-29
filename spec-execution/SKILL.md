---
name: spec-execution
description: Guidelines for implementing features based on specification documents. Use this skill when the user asks you to implement a spec, work through a spec, or complete a feature defined in a spec file.
---

# Spec Execution

## Spec Location

Spec files live in `.specs/` at the repo root, named `SPEC-XX-Feature-Name.md`. A request like `SPEC-04.2` resolves to the section heading `### 4.2 ...` inside `.specs/SPEC-04-...md`.

## Scope Selection

Specs stay in a single file even when they are split into smaller execution units.

- Full-spec execution targets the whole file, for example `SPEC-03` or `implement the whole spec`
- Section-scoped execution targets one numbered implementation section inside that same file, for example `SPEC-03.1`, `3.1`, or `implement section 3.1`
- `SPEC-03.1` maps to the section heading `### 3.1 ...` inside `SPEC-03-...md`
- A section request does NOT mean creating or editing a separate subsection file

If the requested section depends on an earlier incomplete section, call that dependency out before proceeding.

## Workflow

When implementing a spec:

### 1. Create a Todo List


Use whichever you already have between the manage_todo_list tool or Task tools (TaskCreate/TaskUpdate/TaskList) to create and track a structured list of tasks based on the requested scope.

- For a full spec, include the requirements from every numbered section in the spec
- For a single section such as `SPEC-04.2`, include only the requirements under that numbered section plus the relevant verification work
- Each checkbox in the requested scope should become a todo item when practical

```
Example:
- [ ] Implement 3.1 preview entry
- [ ] Show 3.1 filename and bank details
- [ ] Add tests for 3.1 behavior
- [ ] Verify 3.1 UI by using the browser using whatever tool you have - the #browser tool, or Playwright MCP otherwise
```

### 2. Work Through Items Sequentially

- Mark each todo as **in-progress** before starting work
- Mark each todo as **completed** immediately after finishing
- Only have **one item in-progress** at a time

### 3. Update the Spec File During and After Execution

When implementing a single numbered section:

1. Change the spec's **Status** to `🚧 In Progress` if the spec is not already complete
2. Check only the checkboxes inside the completed numbered section
3. Leave unrelated sections unchanged
4. Do **not** mark the spec `✅ Complete` until every numbered section is done

If the completed work finishes the final remaining numbered section in the spec:

1. Change the spec's **Status** from `📋 Not Started` or `🚧 In Progress` to `✅ Complete`
2. Check all remaining checkboxes (`- [ ]` → `- [x]`)

If other numbered sections still remain after the requested work:

1. Keep the spec `🚧 In Progress`
2. Leave the remaining sections' checkboxes untouched

## Section-Level Rules

- Execute numbered sections in order unless the spec clearly says otherwise
- Do not silently expand a section request into the whole spec unless the requested section cannot stand alone
- If a section request requires prerequisite work from an earlier section, explain the dependency and resolve it with the user before broadening scope
- Keep edits, tests, and spec checkbox updates limited to the requested section whenever possible

## Completion Checklist

Before marking a spec as complete, ensure:

- [ ] All numbered section requirements are implemented
- [ ] Tests are written for all features
- [ ] Any UI changes are verified by using the browser using whatever tool you have - the #browser tool, or Playwright MCP otherwise
- [ ] Spec file is updated with checked boxes
- [ ] Status is changed to ✅ Complete

## README Updates

**When a spec adds new user-facing features**, update the README.md file to document the new functionality (if the project keeps user-facing docs there).

- Only update the README for **user-visible feature additions**
- Bug fixes, refactoring, and internal changes do not require README updates
- Add new sections/pages to the README if they are created
- Update existing descriptions when new features are added
