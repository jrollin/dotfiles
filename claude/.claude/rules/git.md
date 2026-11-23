## Git rules

- Never commit without explicit user validation in the current turn
  - "explicit" means the user typed something like "commit", "ok commit", or equivalent
  - not "looks good", not "the work is done", not implied approval
  - same rule for `git push`, `git rebase`, `git reset --hard`, force push, branch delete
  - after finishing any task that produced changes, STOP at "ready to commit", describe what's
    staged or stageable, then wait
  - if unsure whether the user's message is a commit instruction, ask
- Quality checks required before commit:
  - Tests pass
  - Linting passes
  - Formatting applied
  - Code review (manual or automated)
- Commit messages must pass `@commitlint/config-conventional`
  - a repo `.commitlintrc*` / `commitlint.config.*` overrides it: read it before drafting
  - header `type(scope): subject`, ≤100 chars, no leading/trailing whitespace
  - type lower-case, one of `build` `chore` `ci` `docs` `feat` `fix` `perf` `refactor`
    `revert` `style` `test`
  - scope optional
  - subject not empty, no trailing `.`, never Sentence/Start/Pascal/UPPER case
    (`fix(auth): handle expired token`, not `fix(auth): Handle expired token`)
  - blank line before body and before footer
  - body and footer lines ≤100 chars, hard-wrap bullets too
  - breaking change: `!` before `:` or a `BREAKING CHANGE:` footer
- Never add a signature or co-author line (e.g. `Co-Authored-By`) to commit messages
- Force pushes always use `git push --force-with-lease`.
