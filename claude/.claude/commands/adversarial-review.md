---
description: Adversarial pre-commit review of the diff vs main, then fix findings with regression tests
---

# Adversarial pre-commit review

One-shot review of the uncommitted work, then fix what is real.

## 1. Scope

Determine the base branch (`main`, else `master`) and collect the diff:

```bash
git diff $(git merge-base HEAD main)...HEAD
git diff            # unstaged
git diff --cached   # staged
```

If the diff is empty, say so and stop.

## 2. Review

Spawn one `Agent` (`subagent_type: general-purpose`) with the diff scope and this brief:

> You are an adversarial reviewer. Assume the author is wrong. Hunt for blockers only:
> correctness bugs, security holes, race conditions, unhandled errors, resource leaks,
> and edge cases (empty, null, boundary, concurrent, partial failure).
> Ignore style, naming, and formatting.
> For each finding report: severity (blocker | major | minor), `file:line`, one sentence
> on the defect, and a concrete failure scenario (inputs or state -> wrong result).
> No finding without a failure scenario. Report nothing rather than pad the list.

## 3. Verify

Reproduce each finding before touching code. Drop any you cannot trigger, and say which
ones you dropped and why. Sub-agents report false positives.

## 4. Fix

For every confirmed finding, in severity order:

1. Write the failing regression test first, run it, confirm it fails for the stated reason
2. Fix the code
3. Re-run the narrowest suite that covers the fix (the touched test file, not the whole suite)

Run the full suite once at the end, not per finding. If it is slow (minutes), or you cannot
scope a narrow run, ask before running it rather than blocking on it.

## 5. Report

Table of findings: severity, `file:line`, verdict (fixed | dropped | deferred), test added.
Then stop at "ready to commit". Do not commit.
