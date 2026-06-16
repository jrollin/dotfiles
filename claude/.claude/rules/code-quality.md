## Code quality rules

- No dead code — delete it, don't comment it out
- No TODO/FIXME without a linked issue or explicit deferral note
- Error messages must include enough context to debug (what failed, where, why)
- Prefer explicit over clever
- Prefer immutability and pure functions where possible
- Keep functions short and single-purpose
- No copy-paste duplication — extract only when 3+ occurrences of duplicated logic exist (not merely similar-looking lines)
- Comments only when WHY is non-obvious — never narrate WHAT the code does
  - Bad (restates code): `# increment counter` above `counter += 1`
  - Good (explains why): `# API rate-limits at 10 req/s, so we batch`
- Keep comments terse — one short line; no multi-line/multi-paragraph blocks or verbose docstrings
- Default to writing concise comments without being asked — this is a standing preference, not a per-request instruction
- No speculative abstractions — don't design for hypothetical future requirements (YAGNI)
- Never reference local project names, local paths, or local config in code, documentation, or pull requests — keep artifacts portable and free of machine- or user-specific details
