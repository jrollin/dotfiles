---
paths:
  - "**/*.rs"
---

## Rust rules

These apply while WRITING Rust, not only when refactoring later. A god-file or god-function is a defect at creation. For depth (worked example, review checklist), use the `rust-decompose` skill; for ports/adapters layering, the `rust-hexagonal` skill.

### Decomposition (write it split)

- One file, one concern. A file that will hold several concerns starts as a directory module `foo/`, not a file you split later
- `mod.rs` / `lib.rs` carry no logic — only `mod` declarations, `pub use` re-exports, and `#[cfg(test)] mod tests`
- A function with distinct named phases (walk → parse → store → resolve) is an orchestrator + one function per phase, written that way from the start
- An owned resource that spans the operation (transaction guard, lock, `&mut` accumulator) stays in the orchestrator — phase functions take a `&` / `&mut` reference, never own it across the call
- Pure / CPU phases take immutable inputs and return owned data; only the orchestrator mutates shared state
- Tests split by concern under `tests/`, one topic per file; shared helpers in `tests/mod.rs`

### Idiomatic baseline

- `Result<T, E>` for fallible ops, `?` to propagate; never panic on input or external data
- No `unwrap()` / `expect()` outside `main.rs` startup and `#[cfg(test)]` code
- Add `.context()` / `.with_context()` at each fallible I/O or query step, naming what failed + the key input
- Borrow in signatures: `&str` not `&String`, `&[T]` not `&Vec<T>`; own only to store, move, or consume
- No `.clone()` to silence the borrow checker — restructure (cheap `Arc` clones excepted)
- Newtypes for domain values, enums over boolean-flag sets for state — make illegal states unrepresentable

### See also (do not duplicate)

- General refactoring discipline (move-only, test-the-seam, no mixed feature+refactor): refactoring rules
- Comments, dead code, error-message standard: code-quality rules
- Regression-first, real-deps-at-integration: testing rules
