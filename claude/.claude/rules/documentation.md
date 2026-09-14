---
paths:
  - "**/*.md"
  - "**/*.mdx"
  - "**/*.adoc"
  - "**/*.rst"
  - "**/README*"
  - "**/CHANGELOG*"
  - "**/docs/**"
  - "**/adr/**"
  - "**/ADR/**"
---

## Documentation rules

- README must reflect current state — not aspirational
- API changes require updated examples
- Architecture decisions go in ADR format when the project uses ADRs
- CHANGELOG follows Keep a Changelog format when the project has one

## Writing style

- Before authoring or editing any doc, invoke the `claudio-craft:writing-style` skill and follow it
- Use `/writing-style` review mode when auditing existing prose
- The skill is the single source of truth for prose style: do not restate its rules here
