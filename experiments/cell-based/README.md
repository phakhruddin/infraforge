# Cell-Based Architecture

This section documents the cell-based architecture operating model, including design decisions, trade-offs, and implementation considerations.

## Documents

- [`rfc.md`](./rfc.md) — formal architecture design (problem, constraints, design, alternatives, trade-offs, decision)
- [`engineering-discovery.md`](./engineering-discovery.md) — practical insights and operational lessons

## Summary

Cell-based architecture splits a large platform into smaller isolated units called **cells** to reduce blast radius and improve fault isolation.

The primary trade-off is increased platform engineering complexity across routing, observability, deployment, and operations.

Refer to the RFC document for the full design and decision rationale.
