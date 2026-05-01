# RFC: Cell-Based Architecture Operating Model

## Status

Draft

## Context

Large cloud-native platforms often begin as shared systems. Over time, shared platforms accumulate many workloads, tenants, deployment pipelines, dependencies, and operational responsibilities.

This increases the impact of failure. A single bad deployment, noisy tenant, overloaded dependency, misconfigured policy, or capacity event can affect a large portion of the platform.

Cell-based architecture proposes splitting the platform into smaller, mostly isolated units called **cells**. Each cell owns enough infrastructure and application capability to serve a bounded portion of traffic, tenants, regions, workloads, or shards.

## Problem

The current shared-platform model creates large blast-radius risk.

A failure in one part of the system can spread across unrelated tenants, services, or workloads. This makes incidents harder to isolate, harder to debug, and more expensive operationally.

The platform needs a model that can:

- contain failures inside smaller boundaries
- support safer deployments
- reduce noisy-neighbor impact
- enable more predictable capacity ownership
- preserve enough shared platform capability to avoid unnecessary duplication

The problem is not only technical. It is also operational. A cell-based design changes how teams provision infrastructure, route traffic, observe systems, enforce policy, and handle incident response.

## Constraints

### Reliability constraints

- A single cell failure should not cause platform-wide failure.
- A bad deployment should affect only the targeted cell when possible.
- Failures must be observable at both cell level and platform level.

### Operational constraints

- Cells must be repeatable and automated.
- Cell configuration must avoid drift.
- Teams must be able to provision, update, and retire cells safely.
- Deployment tooling must understand cell targeting.

### Routing constraints

- Requests must be routed to the correct cell.
- Routing decisions must be observable and reversible.
- Failover behavior must be explicit.

### Data constraints

- Data ownership must be clear.
- Cross-cell writes should be avoided unless explicitly designed.
- Shared data dependencies must not become hidden coupling between cells.

### Security constraints

- Identity, authorization, encryption, and audit policies must be consistent across cells.
- Cells should not depend on implicit network trust.
- Policy drift must be detected through automation.

### Cost constraints

- The design will likely require additional baseline capacity per cell.
- The platform must balance isolation benefits against duplicated infrastructure cost.

## Design

### Cell definition

A **cell** is a bounded operational unit that contains the infrastructure and services required to serve a subset of platform traffic or workloads.

A cell may map to:

- a tenant group
- a shard
- a region
- a workload class
- a Kubernetes cluster
- a combination of the above

### Proposed high-level model

```text
                 +----------------------+
                 | Global Control Plane |
                 | routing / policy     |
                 +----------+-----------+
                            |
             +--------------+--------------+
             |                             |
             v                             v
      +-------------+               +-------------+
      |   Cell A    |               |   Cell B    |
      | apps        |               | apps        |
      | ingress     |               | ingress     |
      | telemetry   |               | telemetry   |
      | policies    |               | policies    |
      +-------------+               +-------------+
             |                             |
             v                             v
      Local data / queues           Local data / queues
```

### Global components

Global components should be minimized and carefully controlled.

Examples:

- routing registry
- identity provider
- deployment orchestration
- policy templates
- global observability aggregation
- cell inventory

Global components must not become hidden runtime dependencies that break cell isolation.

### Local cell components

Each cell should contain:

- ingress or gateway boundary
- workload runtime
- local service configuration
- local telemetry emission
- local scaling rules
- local operational ownership

Depending on the implementation, a cell may also contain local queues, caches, databases, or indexes.

### Routing model

Routing should be cell-aware.

Common routing keys:

- tenant ID
- region
- shard key
- customer segment
- workload type

Routing decisions should be logged and observable so engineers can trace which cell handled a request.

### Deployment model

Deployments should support phased rollout by cell.

Example rollout:

```text
cell-dev -> cell-canary -> cell-a -> cell-b -> remaining cells
```

This enables safer release patterns and limits blast radius during deployment failures.

### Observability model

Telemetry must include cell identity.

Minimum required labels:

- cell ID
- region
- service
- environment
- tenant or workload segment when appropriate

The platform should support both:

- local cell debugging
- global fleet comparison

### Security model

Security posture must be applied consistently across cells.

Controls should include:

- service identity
- mTLS or equivalent transport security
- policy-as-code
- secrets management
- audit logging
- automated drift detection

## Alternatives

### Alternative 1: Single shared platform

A single shared platform is simpler to operate at small scale.

Benefits:

- lower operational overhead
- simpler routing
- fewer duplicated components
- easier global visibility

Limitations:

- larger blast radius
- noisy-neighbor risk
- harder deployment isolation
- harder capacity attribution

### Alternative 2: Namespace-level isolation

Kubernetes namespaces can provide logical separation inside a shared cluster.

Benefits:

- lower cost than separate clusters
- simpler management
- useful for lightweight isolation

Limitations:

- shared control plane
- shared cluster failure domain
- weaker hard isolation
- noisy-neighbor issues can remain

### Alternative 3: Per-region architecture only

A platform may isolate by region rather than by cell.

Benefits:

- natural geographic boundary
- useful for latency and compliance
- easier to reason about than many smaller cells

Limitations:

- region failure domains may still be too large
- tenant-level or workload-level isolation is limited
- deployment blast radius can still be broad

### Alternative 4: Full tenant-dedicated stacks

Each tenant receives a dedicated stack.

Benefits:

- strong tenant isolation
- clear ownership
- easier per-tenant compliance controls

Limitations:

- expensive
- heavy operational overhead
- poor utilization for small tenants
- high automation requirements

## Trade-offs

### Reliability vs operational overhead

Cells reduce blast radius, but multiply the number of environments to operate.

### Isolation vs utilization

Stronger isolation usually requires more reserved capacity, which can reduce utilization efficiency.

### Local autonomy vs global consistency

Cells allow local containment, but global policy and configuration must remain consistent.

### Simpler incidents vs harder fleet management

Incidents may be smaller and easier to contain, but fleet-level upgrades, policy enforcement, and observability become more complex.

### Data locality vs cross-cell workflows

Local data ownership improves isolation, but workflows that span cells require careful design.

## Decision

Adopt cell-based architecture only where the platform has clear need for blast-radius reduction, workload isolation, or controlled deployment boundaries.

The initial implementation should start with a small number of cells and prove the operating model before expanding.

The decision includes these requirements:

1. Cells must be provisioned through automation.
2. Every cell must expose standard telemetry with cell identity.
3. Routing must be explicit, observable, and reversible.
4. Security policy must be applied consistently through code.
5. Cross-cell dependencies must be documented and reviewed.
6. Global control-plane components must be minimized.
7. Rollouts must support cell-by-cell deployment.

## Open Questions

- What is the first production-worthy cell boundary: tenant, region, workload, or shard?
- Which components remain global?
- What is the minimum viable cell footprint?
- How much spare capacity is required per cell?
- What failure scenarios must be tested before production use?

## References

- [`engineering-discovery.md`](./engineering-discovery.md)
