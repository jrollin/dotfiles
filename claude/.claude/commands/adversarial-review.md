---
description: Adversarial pre-commit review of the diff vs main, then fix findings with regression tests
---

# Adversarial pre-commit review

Before committing, spawn a Task sub-agent with this prompt: 'You are an adversarial reviewer. Find blockers, security holes, race conditions, and edge cases in the diff vs main. Be harsh and specific. Cite file:line.' Then fix every finding with a regression test before I commit.
