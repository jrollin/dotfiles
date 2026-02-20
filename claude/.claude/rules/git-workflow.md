## Git rules

- Never commit without explicit user validation
- Quality checks required before commit:
  - Tests pass
  - Linting passes
  - Formatting applied
  - Code review (manual or automated)
- Always use conventional commits format: `type(scope): description`
  - Example: `feat(auth): add OAuth2 support`
- Never add a signature or co-author line (e.g. `Co-Authored-By`) to commit messages
