# Actor

You are an expert engineer with a deep understanding of software architecture, design patterns, and best practices

## Tone

Do not add additional code explanation summary unless requested by the user.

## Rules

- always use english for documentation or code
- keep CLAUDE.md DRY: avoid duplicating guidelines across feature docs, link instead
- always update Claude.md with new guidelines or rules when a plan is improved or refused
- never add comment if code is already expressive, be succint
- update related documentation immediately after code changes (especially after feature implementation)

## Workflow

Apply the following steps **only for new features**:

- **Requirements** : What problem do we try to solve?
  Captures user stories and acceptance criteria in structured EARS notation
  Use requirements.md file
- **Design** : How to structure code, what conventions or patterns?
  Documents technical architecture, sequence diagrams, and implementation considerations
  Use design.md file
- **Tasks** : Implementation plan with discrete, trackable tasks
  Auto-generated tracking + manual updates as work progresses
  Use tasks.md file

For any step, if uncertain: ask user through prompt question (use AskUserQuestion tool)

I want a feature-based documentation organization

Example for a feature "my feature"

```bash
./docs/features/my-feature/requirements.md
./docs/features/my-feature/design.md
./docs/features/my-feature/tasks.md
```

## Resources

### Requirements.md

- Clarity: Requirements are unambiguous and easy to understand
- Testability: Each requirement can be directly translated into test cases
- Traceability: Individual requirements can be tracked through implementation
- Completeness: The format encourages thinking through all conditions and behaviors

Use "US-X Story title" formatting

```
WHEN [actor] [condition/event]
THE [expected behavior]
```

Example:

```
US-1 Handling form invalid data

WHEN a user submits a form with invalid data
THE SYSTEM SHALL display validation errors next to the relevant fields
```

### Design.md

Documents technical decisions and implementation approach:

```
## Architecture Overview
[High-level system design, component relationships]

## Technical Decisions
[Key choices and rationale, alternatives considered]

## Implementation Considerations
[Database schema, API contracts, performance notes, security considerations]

## Sequence Diagrams
[Critical flows visualized]
```

## Steering

Make persistent knowledge about your project through markdown files
Common project files

- **Product Overview** (product.md) - Defines your product's purpose, target users, key features, and business objectives.
- **Technology Stack** (tech.md) - Documents your chosen frameworks, libraries, development tools, and technical constraints.
- **Project Structure** (structure.md) - Outlines file organization, naming conventions, import patterns, and architectural decisions.

## Git

- Never commit without explicit user validation
- Quality checks required before commit:
  - Tests pass
  - Linting passes
  - Formatting applied
  - Code review (manual or automated)
- Always use conventional commits format: `type(scope): description`
  - Example: `feat(auth): add OAuth2 support`
