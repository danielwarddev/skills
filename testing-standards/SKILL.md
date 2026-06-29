---
name: testing-standards
description: 'Use when writing or reviewing unit tests or integration tests for .NET/C# code. Covers test project selection, naming, setup patterns, behavior-first assertions, and required build/test checks. For UI/component testing (bUnit) guidance, use the blazor-frontend skill.'
argument-hint: 'Testing task, affected project, or changed behavior'
---

# Testing Standards

## When to Use

- Add or update automated tests for .NET code changes.
- Decide whether a change needs unit or integration coverage. (For UI/component coverage, use the blazor-frontend skill.)
- Review a test for brittleness, missing coverage, or implementation-detail coupling.
- Verify completion for spec-driven work.

## Procedure

1. Identify the behavior that changed and choose the smallest test level that can verify it reliably.
2. Select the matching test project and mirror the source structure when practical.
3. Write behavior-focused tests using the repo's libraries and naming conventions.
4. Run the relevant verification commands before considering the work complete.
5. If the change affects anything in the UI, run the app and navigate the relevant user flows with the `#browser` tool, or with Playwright if `#browser` is not sufficient, to confirm the UI both works and looks as expected.
6. If the work came from a spec in `.specs/` (repo root), update the acceptance checkboxes and status as the testing work is completed.

## Choosing the Test Type

- Use unit tests for one behavior in isolation, especially branching, transformations, and explicit error handling.
- Use integration tests for multiple units working together, end-to-end flows, or file input/output behavior.
- For UI/component tests (e.g. bUnit), use the blazor-frontend skill.
- Do not add tests for pure delegation, configuration wiring, or default framework behavior unless the code adds its own logic.

## Choosing the Test Project

- Use the test project that corresponds to the source project under test (typically named `<Project>.UnitTests` or `<Project>.Tests`).
- Keep test files aligned with the source area they cover. For example, tests for a `Components\` folder in the source project live under the matching `Components\` folder in the test project.

## Test Conventions

- Use xUnit with AwesomeAssertions, NSubstitute, and AutoFixture. (For component testing with bUnit, use the blazor-frontend skill.)
- Do not create custom fake classes in tests when NSubstitute can express the behavior. Prefer `Substitute.For(...)` test doubles over handwritten fakes.
- Name tests `When_<action>_Then_<expected_result>`, with every word separated by an underscore. The only exception is a codebase identifier (method name, class name, property name) used verbatim — treat that as a single unit (e.g., `When_ComputeHash_Called_Then_Returns_Sha256_Hex_String` where `ComputeHash` is a method being tested). Never merge plain English words without a separating underscore.
- Use Arrange, Act, Assert structure without section comments.
- Prefer collection expressions in test setup and assertions when the target type is clear instead of `new List<T>()` or `new List<T> { ... }`.
- If the repository later adds database-involved tests, use the real provider behavior over `Microsoft.EntityFrameworkCore.InMemory`. NEVER use SQLite or the in-memory provider.
- When using NSubstitute `Returns(first, second, ...)` for sequential values, do not pass a bare empty collection expression like `[]` as a later argument. Assign it to a typed local first so NSubstitute does not interpret it as an empty set of additional return values.
- Prefer class-level test doubles and initialize the SUT in the constructor when setup is shared. xUnit creates a new test class instance for every test, so constructor initialization is safe and exactly equivalent to constructing the SUT at the top of each test body.
- Assert behavior, returned values, state changes, or rendered output instead of implementation details.
- When asserting multiple properties on the same returned object or DTO, prefer a single `BeEquivalentTo(...)` assertion over separate per-property assertions when it keeps the expectation clear.
- Avoid `Received()` and `DidNotReceive()` unless the interaction itself is the behavior under test.
- Do not write tests that only prove an uncaught exception bubbles through unchanged.
- Do not make production members more visible solely to unit test them; extract a service or helper when needed.
- Never call external services in tests.
- For simple entity persistence tests, one test that inserts a record and asserts all fields are correct is sufficient. Do not multiply tests across individual fields, optional fields, or enum values.

## Verification

- Run `dotnet build` on the solution for code changes.
- Whenever you add or change automated tests, run `dotnet test` on the solution to verify the changes worked.
- If `dotnet test` fails because of your change, keep making focused fixes and re-running it until it passes.
- If the project has a UI and the change affects it, use the `#browser` tool or Playwright MCP (whichever you have) to navigate the affected user flows. Use Playwright MCP if `#browser` is not available (or sufficient). Keep iterating until the UI works and looks right.
- Do not finish while change-related build or test failures remain.

## Completion Checklist

- The changed behavior is covered by the right automated tests.
- The selected test project matches the source area.
- Assertions verify behavior rather than collaborator calls.
- Build and relevant tests pass.
- Any UI changes are verified with the `#browser` tool, or with Playwright when `#browser` is not available (or sufficient), and the affected flows both work and look right.
- Spec files are updated when the work implements acceptance criteria.
