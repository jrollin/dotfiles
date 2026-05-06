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
- Wrap commit message body lines at ≤100 chars (commitlint `body-max-line-length` default)
  - Check `.commitlintrc*` for stricter project-specific limits before drafting
  - Applies to bullet lists too — long bullets must be hard-wrapped, not single-line
