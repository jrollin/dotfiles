---
paths:
  - "**/*.test.*"
  - "**/*.spec.*"
  - "**/__tests__/**"
  - "**/tests/**"
  - "**/test/**"
  - "**/cypress/**"
  - "**/e2e/**"
---

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
