# infraforge

**Real-world cloud architecture patterns at scale — including the nuance, trade-offs, and engineering complaints that do not always show up in polished reference diagrams.**

`infraforge` is a learning and architecture workspace for capturing practical infrastructure patterns, platform engineering experiments, and system design notes.

The goal is not only to document *what* a pattern is, but also:

- why engineers use it
- where it helps
- where it hurts
- what trade-offs appear at scale
- how to explain it in interviews or design reviews

## Repository Structure

```text
infraforge/
├── experiments/
│   └── cell-based/
│       ├── README.md
│       └── engineering-discovery.md
└── README.md
```

## Experiments

### Cell-Based Architecture

Cell-based architecture splits a large platform into smaller isolated units called **cells**. Each cell can serve a subset of tenants, traffic, workloads, regions, or customers.

The main benefit is **blast-radius reduction**.

The main engineering trade-off is that each cell can become a mini-platform, increasing operational overhead across routing, observability, security, capacity planning, and data consistency.

Start here:

- [`experiments/cell-based/README.md`](./experiments/cell-based/README.md) — overview, trade-offs, interview summary, and practical design principles
- [`experiments/cell-based/engineering-discovery.md`](./experiments/cell-based/engineering-discovery.md) — deeper notes on what engineers discover when operating or evaluating cell-based systems

## How to Use This Repo

Use this repository as a field guide for cloud architecture thinking.

Each topic should eventually include:

- a short overview
- real-world engineering complaints
- design trade-offs
- implementation notes
- interview-ready explanation
- links to deeper docs inside the same topic folder

## Writing Style

Architecture notes in this repo should stay practical and experience-driven.

Prefer:

- concrete trade-offs over vague best practices
- engineering complaints over marketing language
- operating-model details over pure theory
- simple diagrams and examples when useful

## Commit Message Convention

Use conventional commit style:

```text
feat(scope): add new architecture experiment
fix(scope): correct inaccurate explanation
docs(scope): update architecture notes
refactor(scope): reorganize documentation
chore(scope): repository maintenance
```

Examples:

```text
docs(cell-based): add engineering discovery notes
docs(root): update landing README
feat(experiments): add new routing strategy notes
fix(cell-based): clarify cross-cell data consistency tradeoff
```
