## Refactoring rules

### When to split (god-file / god-function)

- Split a file when it mixes >1 concern AND is large enough that finding code is slow — not on line count alone
- Split a function when it has distinct sequential phases that each have a name (walk → parse → store → resolve)
- Default to move-only / additive splits: no behavior change. Behavior changes land separately
- Keep each split reviewable as "did this move, nothing else?" — no unrelated changes riding along
- Never mix a refactor with a feature or bug fix — if you spot a bug mid-refactor, fix it as a separate change

### Directory-module pattern (file → directory)

- A god-file `foo` → a `foo/` directory with one submodule per concern; tests move to `foo/tests/<concern>`
- The directory's aggregator/index file stays tiny: submodule declarations + re-exports + test wiring — never logic
- Re-export from the submodule, don't fatten the package/index/aggregator file
- Split tests by concern, one topic per file; shared helpers go in a common test-support module
- Preserve public/exported names and signatures across a move-only split — callers must not change; a name change is a separate change

### Function → phase functions

- Extract each phase to a named function; the original becomes a thin orchestrator that calls them in order
- Identify the invariant the single function guaranteed by construction (one open resource, one lock, one shared accumulator) and decide who owns it
- Owned resources (open handle/connection, lock, mutable accumulator) stay in the orchestrator and DO NOT cross a function boundary — phase functions receive a reference and operate within it
- Document the preserved invariant on the orchestrator and on each phase function (e.g. "all steps share one unit of work; a failure before commit discards them all")
- Pure / compute phases take immutable inputs and return data; only the orchestrator mutates shared state

### Test the invariant, not the move

- A move-only refactor still needs NEW tests when the split moved an invariant across a function boundary — test the invariant a regression could now break
- Cover the seam: a mutable accumulator threaded through a loop (does it accumulate across all iterations?), partial-failure rollback (does it span every extracted phase, not just the first?)
- A move-only split must leave the existing suite green with no test edits — edited assertions mean behavior changed (see testing rules)
- Invariants newly exposed by a refactor get the same failing-regression-test-first discipline as bug fixes (see testing rules)

### Errors at the boundary

- When extracting I/O or query helpers, wrap each fallible step with context naming what failed + the key input — the split is the moment to fix thin error messages
- See code-quality rules for the what/where/why error standard
