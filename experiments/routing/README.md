# Routing Strategies

Routing is the control point that decides where traffic should go across services, cells, clusters, regions, and tenants.

In large cloud platforms, routing is not only about load balancing. It becomes a reliability, security, deployment, and blast-radius control mechanism.

## Why This Matters

Routing strategy determines how the platform handles:

- tenant-to-cell mapping
- regional failover
- blue/green and canary deployments
- service discovery
- dependency isolation
- ingress and egress control
- traffic shaping during incidents

A weak routing model can undo the benefits of otherwise strong architecture.

## Common Patterns

### Global Edge Routing

Traffic enters through a global edge layer such as DNS, CDN, global load balancer, or API gateway.

Used for:

- regional routing
- latency-based routing
- disaster recovery
- high-level traffic steering

### Cell-Aware Routing

Requests are routed to a specific cell based on tenant, shard, geography, workload type, or routing metadata.

Used for:

- blast-radius containment
- tenant isolation
- predictable ownership
- safer deployments

### Service Mesh Routing

Service-to-service traffic is managed through a mesh or sidecar/data-plane model.

Used for:

- mTLS
- retries
- circuit breaking
- traffic splitting
- policy enforcement

### Gateway-Based Routing

Ingress gateways, API gateways, or Kubernetes Gateway API resources provide centralized control over routing rules.

Used for:

- external service exposure
- protocol handling
- auth integration
- rate limiting
- request transformation

## Engineering Complaints

Routing becomes painful when:

- routing rules are scattered across too many systems
- failover logic is unclear
- traffic ownership is not documented
- routing state drifts from infrastructure state
- engineers cannot easily answer which path a request took

The core complaint:

> Routing starts simple, then quietly becomes the platform control plane.

## Design Questions

Ask these before choosing a routing model:

- What decides the target: DNS, gateway, service mesh, app logic, or control plane?
- Is routing tenant-aware, region-aware, cell-aware, or workload-aware?
- How is failover triggered?
- Is failover automatic, manual, or progressive?
- How do we observe routing decisions?
- How do we roll back bad routing changes?

## Interview Summary

> Routing strategy is not just traffic distribution. At scale, routing becomes a reliability and isolation mechanism. The strongest designs make routing decisions explicit, observable, and reversible.
