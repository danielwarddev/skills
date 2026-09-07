# Writing Tests

Read this before adding or changing any automated test.

Tests are not an afterthought. Use them early to shape the design, not as paperwork
filed after the code works.

## Choosing the Test Level

Pick the smallest level that can verify the changed behavior reliably.

| Behavior | Test type |
|---|---|
| One unit in isolation — branching, transformation, explicit error handling | Unit test |
| Several units together, an end-to-end flow, or file input/output | Integration test |

UI and component rendering are covered by the UI framework's own skill.

## What Not to Test

- Pure delegation — a method whose only job is to forward a call.
- DI registration and service wiring. Do not add tests that only assert a service was
  registered; rely on build and runtime validation unless the wiring contains real
  application logic.
- Default framework behavior the code does not modify.
- That an uncaught exception bubbles through unchanged.

Never call external services from a test.

## Test Project and Layout

Put the test in the existing test project that corresponds to the source project under
test, and mirror the source path inside it:

```
<SourceProject>\Orders\OrderPricingService.cs
<TestProject>\Orders\OrderPricingServiceTests.cs
```

## Naming

Name tests `When_<action>_Then_<expected_result>`, with **every word separated by an
underscore**.

The only exception is a codebase identifier — a method, class, or property name used
verbatim — which counts as a single unit:

```csharp
// Good — ComputeHash is a method name, so it stays intact
When_ComputeHash_Called_Then_Returns_Sha256_Hex_String

// Bad — plain English words merged without a separator
When_ComputeHash_Called_Then_ReturnsSha256HexString
```

## Naming the System Under Test

Never name the system under test `sut`. Name it for what it actually is — the reader
should not have to look up a declaration to know what is being exercised.

```csharp
// Good
var pool = CreatePool(1);
var validator = new ThemeValidator();

// Bad
var sut = CreatePool(1);
```

The same applies to fields holding a class-level system under test. `sut` carries no
information that the type name does not already carry better.

## Conventions

- xUnit with AwesomeAssertions, NSubstitute, and AutoFixture.
- Keep tests deterministic. Substitute integration boundaries such as external
  services, clocks, random-number generators, and environment-dependent resources.
- Use `Substitute.For<T>()` rather than handwritten fake classes whenever NSubstitute
  can express the behavior.
- Arrange / Act / Assert structure, without section comments.
- Omit the blank lines between Arrange/Act/Assert when each section is only one line
  (or the test is two lines total, e.g. Act+Assert with no separate Arrange). Add a
  blank line between sections only once a section grows past one line, so the blank
  line is doing real work separating multi-line groups.
- Prefer collection expressions in setup and assertions when the target type is clear.
- Keep simple test setup inline instead of hiding it behind a helper that only performs
  trivial construction or forwards arguments. Extract setup only when the helper removes
  meaningful repetition or makes the test's intent clearer.
- Prefer class-level test doubles with the SUT initialized in the constructor when
  setup is shared. xUnit constructs a new test class instance per test, so this is
  exactly equivalent to building the SUT at the top of each test body.
- In database-backed tests built on the repository's test base class, initialize the SUT
  once in the constructor from the base class's context factory and store it in a
  `private readonly` field. Do not call a `CreateService()` helper in every test method.
- When asserting several properties of one returned object, prefer a single
  `BeEquivalentTo(...)` over separate per-property assertions where it keeps the
  expectation clear.
- With NSubstitute's sequential `Returns(first, second, ...)`, do not pass a bare `[]`
  as a later argument — assign it to a typed local first, or NSubstitute reads it as an
  empty set of additional return values.
- Do not test only the happy path. For every new or changed decision point, cover both
  outcomes when they produce observable, meaningful behavior; include error, empty, or
  unavailable states where applicable.

## Assert Behavior, Not Interactions

Assert returned values, state changes, and rendered output rather than implementation
details.

Avoid `Received()` and `DidNotReceive()` unless the interaction itself is the behavior
under test — for example, when the collaborator owns the mutable state and there is no
other way to observe the outcome.

Do not widen the visibility of a production member just to test it. Extract a service
or helper instead.

## Self-Check

- [ ] Is this the smallest test level that verifies the behavior?
- [ ] Does the test path mirror the source path?
- [ ] Does every test name separate plain English words with underscores?
- [ ] Is the system under test named for its actual type or role rather than `sut`?
- [ ] Is the test deterministic, with integration boundaries substituted?
- [ ] Is simple test setup inline rather than hidden behind trivial helpers?
- [ ] Are blank lines between Arrange/Act/Assert omitted when each section is one line?
- [ ] Do assertions check behavior rather than collaborator calls?
- [ ] Any test that only proves delegation, wiring, or framework defaults?
- [ ] Was production visibility changed just to enable a test?
- [ ] Does each database-backed test initialize its SUT once in the constructor?
- [ ] Build and tests run using the repository's documented commands?