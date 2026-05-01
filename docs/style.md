# Documentation Style Guide

This guide defines the writing standards for documentation in this repository.

The goal is to keep the repository practical, consistent, and useful for engineers who want to understand architecture patterns, trade-offs, and operational behavior.

## Principles

Documentation should be clear, direct, and implementation-oriented.

Prefer engineering clarity over polished marketing language.

Write for engineers who need to understand:

- what the pattern is
- why it exists
- where it works
- where it fails
- how to operate it
- what trade-offs matter

## Punctuation

### Do not use em dashes

Do not use this character anywhere in repository documentation:

```text
—
```

Use a comma, period, colon, or parentheses instead.

Preferred:

```text
Routing is not only traffic distribution, it is also a reliability control point.
```

Avoid:

```text
Routing is not only traffic distribution — it is also a reliability control point.
```

### Keep punctuation simple

Prefer simple sentence boundaries.

Use:

- commas for light separation
- periods for complete thoughts
- colons before lists or explanations
- parentheses only when they improve clarity

Avoid punctuation that makes docs feel conversational or dramatic.

## Tone

Use a calm, practical engineering tone.

Prefer:

- precise explanations
- concrete trade-offs
- operational constraints
- failure modes
- implementation notes

Avoid:

- motivational language
- hype language
- interview framing
- sales language
- vague best practices

### Preferred tone

```text
Cell-based architecture reduces blast radius, but increases platform operating overhead.
```

### Avoided tone

```text
This is a killer architecture pattern for interviews.
```

## Structure

Use predictable document structure so readers can scan quickly.

For architecture topics, prefer this structure:

```text
# Title

## Context
## Problem
## Constraints
## Design
## Alternatives
## Trade-offs
## Operational Considerations
## Failure Modes
## Decision
## References
```

Not every document needs every section. Use only the sections that help the reader.

## Headings

Use sentence-style headings.

Preferred:

```text
## Operational considerations
## Failure modes
## Routing model
```

Avoid overly promotional headings:

```text
## Why this is powerful
## Game-changing design
## Killer insight
```

## Lists

Use lists for scanability, but keep them focused.

Good lists contain related items only.

Avoid mixing concepts from different layers in the same list unless the section explains the relationship.

## Diagrams

Use text diagrams when they make flow or ownership easier to understand.

Keep diagrams simple and label boundaries clearly.

Example:

```text
Client
  |
  v
Route53
  |
  v
ALB
  |
  v
EKS Service
  |
  v
Pod
```

## Commit messages

Use conventional commit style.

Examples:

```text
feat(routing): add cell-aware routing notes
docs(cell-based): add RFC-style design record
fix(observability): clarify ingestion failure mode
chore(docs): add style guide
```

Use `docs(scope)` for documentation-only changes.

Use `feat(scope)` when adding a new topic, experiment, or major content area.

Use `fix(scope)` when correcting inaccurate or misleading documentation.

## Repository voice

This repository should read like an engineering field guide.

It should help readers understand real systems, not memorize terminology.

Prioritize:

- practical examples
- trade-off analysis
- failure behavior
- operational ownership
- scaling limits
- security and reliability implications
