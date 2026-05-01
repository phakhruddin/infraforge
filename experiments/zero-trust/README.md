# Zero Trust Architecture

Zero Trust is a security model where no component is implicitly trusted, even inside the network boundary.

Every request must be authenticated, authorized, and validated.

## Why This Matters

Traditional perimeter security assumes internal trust.

Modern systems require:

- identity-based access
- service-to-service authentication
- encryption everywhere
- least privilege

## Core Concepts

- identity as the security boundary
- mutual TLS (mTLS)
- short-lived credentials
- policy-based authorization
- continuous verification

## Common Patterns

### Identity Providers (IdP)

Central systems that issue identities and tokens.

### Service Identity

Each workload has its own identity.

### Policy Enforcement

Requests are evaluated against policies before being allowed.

## Engineering Complaints

- complex to implement
- hard to debug
- identity sprawl
- policy drift

Core complaint:

> Zero trust improves security, but increases system complexity significantly.

## Design Questions

- how are identities issued?
- how are identities validated?
- where are policies enforced?
- how is trust established between services?

##  Summary

> Zero trust replaces network-based trust with identity-based trust. It improves security but requires strong identity, policy, and observability systems to operate effectively.
