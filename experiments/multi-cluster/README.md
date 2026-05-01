# Multi-Cluster Kubernetes

Multi-cluster architecture is used to scale Kubernetes beyond a single cluster boundary.

Clusters may represent:

- regions
- environments
- cells
- compliance boundaries
- workload isolation

## Why This Matters

Single clusters eventually hit limits:

- control plane scalability
- failure blast radius
- noisy neighbors
- upgrade complexity

Multi-cluster solves these, but introduces new problems.

## Common Patterns

### Active-Active Clusters

Traffic is distributed across clusters.

Used for:
- high availability
- global scaling

### Active-Passive Clusters

Primary cluster handles traffic, backup is used for failover.

Used for:
- disaster recovery

### Cell-Based Clusters

Each cluster is a cell.

Used for:
- isolation
- tenant segmentation

## Engineering Complaints

- Too many clusters to manage
- Configuration drift
- Deployment complexity
- Hard to coordinate upgrades

Core complaint:

> Multi-cluster solves scaling, but shifts complexity into fleet management.

## Design Questions

- What defines a cluster boundary?
- How are clusters discovered?
- How is traffic routed?
- How are deployments coordinated?
