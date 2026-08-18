# Persistence

Read this before adding an entity, a key, a stored model, or an EF migration.

## Keys

Use `int` for primary and foreign keys. Do not introduce `Guid` IDs for these
persistence flows.

## Migrations

Add committed EF migrations only when the repo actually needs them. Do not generate a
migration speculatively or as part of exploratory work.

## Follow the Existing Storage Approach

Before introducing a new storage mechanism, find how the project already persists data
and follow that pattern. A project may store data in a relational database, in files on
disk, or through an external service — do not assume EF Core is in play just because
this is .NET.

## Testing Persistence

- For simple entity persistence, **one** test that inserts a record and asserts all
  fields are correct is sufficient. Do not multiply tests across individual fields,
  optional fields, or enum values.
- Database-backed tests must run against the real database provider, using the
  repository's existing test fixtures and helpers, so they exercise real provider
  behavior, constraints, and query translation. **Never** use SQLite or
  `Microsoft.EntityFrameworkCore.InMemory` as a stand-in.

## Self-Check

- [ ] Are all new keys `int`?
- [ ] Is a migration actually needed, or was it generated out of habit?
- [ ] Does new storage code follow the project's existing persistence pattern?
- [ ] Is persistence covered by one thorough test rather than many per-field tests?
- [ ] Do database-backed tests use the repository's real-provider fixtures and helpers?
