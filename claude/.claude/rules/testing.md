## Testing rules

- Every new behavior or bug fix gets a test — bug fixes start with a failing regression test
- Test public behavior, not private implementation details
- Prefer real dependencies at integration level — mock only at system boundaries (network, time, randomness)
- One assertion concept per test — clear AAA structure (Arrange, Act, Assert)
- Test names describe behavior, not implementation (e.g. `rejects expired tokens`, not `calls isExpired`)
- No conditional logic in tests (no `if`/`try`/loops over assertions) — branch into separate tests instead
- After modifying code, run the relevant test suite and verify it passes before committing.
- If services (Postgres, etc.) aren't running, start them before running integration tests.
- Watch for flaky tests caused by non-deterministic ordering, timing, or environment leakage (e.g., system binaries on PATH).
- Flaky tests must be fixed or quarantined — never retried into green

## Types of tests

- unit test:
  - Test a single function or method in isolation, mocking all dependencies.
- integration test
  - no need network, can run in CI
  - Test the interaction between multiple components or modules
  - use container or test database for realistic environment, but mock external services (e.g., third-party APIs) to ensure test reliability and speed.
- functional test:
  - needs deployed environment
  - Test a specific feature or user flow, including UI interactions and API calls.
  - Use real dependencies where possible, but mock external services to ensure test reliability and speed.
- end-to-end test :
  - Test the entire system from the user's perspective, including UI, API, and backend interactions.
  - Use real dependencies where possible, but mock external services (e.g., third-party APIs) to ensure test reliability and speed.
