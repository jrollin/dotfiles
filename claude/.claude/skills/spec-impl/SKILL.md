---
name: spec-impl
description: Task-by-task implementer that reads a completed spec and executes each task atomically. Use when a feature spec exists and you're ready to implement. Invoke for spec implementation, task execution, spec-driven development.
---

# Spec Implement

Task-by-task implementer that reads a completed specification and executes each task atomically. Reads `docs/features/<feature-name>/` files produced by `/spec-create`.

## Input

```
/spec-impl <feature-name>
```

- `feature-name`: required — must match an existing directory under `docs/features/`

## When to Use

- A feature spec exists (requirements, design, tasks) and you're ready to implement
- Resuming implementation after a session interruption

**Not this skill:** To create or update a spec, use **spec-create**. To implement a single task test-first, use **tdd**.

## Role

You are a spec-driven implementer. You execute tasks from a completed specification one-by-one, ensuring traceability and test coverage.

## Workflow

### 1. Initialize

1. Verify `docs/features/<feature-name>/` exists
2. Read all 3 spec files for full context:
   - `docs/features/<feature-name>/requirements.md`
   - `docs/features/<feature-name>/design.md`
   - `docs/features/<feature-name>/tasks.md`
3. Handle edge cases (see Edge Cases below)

### 2. Identify Current Task

- Find the first task with status "Not Started" or "In Progress"
- If resuming a session, reconstruct state from `tasks.md` — never rely on chat history

### 3. Restate Before Coding

Before touching any code, restate:
- **Goal**: what this task achieves
- **Key files**: files to create or modify
- **Acceptance criteria**: from the task definition
- **Verification method**: how to confirm completion

### 4. Design Sufficiency Check

Before implementing, verify that `design.md` provides enough detail for the current task. If the design is ambiguous, incomplete, or needs updating:
- **Stop immediately** — do not guess or improvise
- Inform the user what is missing or unclear
- Ask the user to update the design using plan mode before continuing
- Do not resume implementation until the design gap is resolved

### 5. Parallel Check

Identify tasks that have no dependencies between them (no shared files, no dependency chain). These can be executed in parallel using subagents to minimize context usage and maximize throughput.

### 6. Implement

- For independent tasks: launch parallel agents
- For dependent tasks: execute sequentially
- Follow the design decisions from `design.md`

### 7. Validate

Run the verification defined in the task. A task is not complete until its tests pass (unit, integration, or manual verification script).

### 8. Update tasks.md

Mark task as Complete with:
- Short summary of changes
- Test results

### 9. Repeat

Move to next batch of unblocked tasks.

### 10. Completion

When all tasks are done:
- Summarize what was implemented
- When `status.md` exists in feature dir, update implementation progress

## Edge Cases

| Edge Case | Behavior |
|-----------|----------|
| `docs/features/<name>/` doesn't exist | List existing feature dirs under `docs/features/`, suggest closest match. If none exist: "No specs found. Run `/spec-create <name>` first." |
| `tasks.md` missing but requirements/design exist | Error: "Spec incomplete — tasks.md missing. Complete spec with `/spec-create <name>`." |
| Design insufficient for current task | Stop implementation. Inform user what is missing. Ask user to update design via plan mode before continuing. |
| All tasks already Complete | Inform user, ask if they want to add new tasks or review |
| New work discovered during implementation | Ask user to confirm, then add to `tasks.md` — never work on unlisted tasks |
| Task blocked by unresolved dependency | Skip to next unblocked task, inform user |
| Session interrupted mid-task | On resume, read `tasks.md` to find in-progress task, continue from there |

## Constraints

### MUST DO

- Read all 3 spec files at start for full context
- Verify design is precise enough before each task — stop and ask for design update if not
- Ensure all work is tracked in `tasks.md` — no unlisted work
- Identify independent tasks that can run in parallel (no shared files, no dependency chain)
- Use parallel subagents for independent tasks to minimize context token usage
- Restate task goal/files/AC before coding
- Run tests defined in the task's verification — a task is not done until tests pass
- Update `tasks.md` after each task completion with test results
- When `status.md` exists in feature dir, update implementation progress

### MUST NOT DO

- Mark a task as Complete without passing tests
- Skip tasks or work out of order (unless blocked)
- Work on tasks not listed in `tasks.md`
- Parallelize tasks that touch the same files or have dependency chains
- Rely on chat history — always reconstruct from files
- Improvise when design is ambiguous — always stop and ask for clarification

## Related Skills

- **spec-create** — Creates the spec that spec-impl executes
- **tdd** — Can be used within spec-impl for test-driven task execution
