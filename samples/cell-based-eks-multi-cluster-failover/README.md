# Multi-cluster cell failover sample

This sample demonstrates a cell-based Kubernetes architecture where each cell runs in a separate EKS cluster and traffic can fail over between cells.

The goal is to show the minimum practical structure for multi-cluster cells, GitOps deployment, routing, and failure simulation.

## Architecture

```text
Client
  |
  v
Route53
  |
  +-- primary record -> cell-a ALB -> EKS cluster cell-a
  |
  +-- failover record -> cell-b ALB -> EKS cluster cell-b

Git repository
  |
  v
Argo CD ApplicationSet
  |
  +-- deploy app overlay to cell-a cluster
  |
  +-- deploy app overlay to cell-b cluster
```

## What this sample includes

```text
samples/cell-based-eks-multi-cluster-failover/
├── README.md
├── terraform/
│   ├── providers.tf
│   ├── variables.tf
│   ├── main.tf
│   ├── route53-failover.tf
│   └── outputs.tf
├── gitops/
│   ├── argocd/
│   │   └── applicationset-multi-cluster.yaml
│   ├── clusters/
│   │   ├── cell-a-cluster.yaml
│   │   └── cell-b-cluster.yaml
│   ├── apps/
│   │   ├── base/
│   │   └── overlays/
│   │       ├── cell-a/
│   │       └── cell-b/
│   └── routing/
│       ├── cell-a-ingress.yaml
│       └── cell-b-ingress.yaml
├── runbooks/
│   └── simulate-cell-failover.md
└── scripts/
    └── validate.sh
```

## Cell model

| Cell | Cluster | Role | Routing behavior |
|---|---|---|---|
| cell-a | EKS cluster A | primary | receives traffic during normal operation |
| cell-b | EKS cluster B | failover | receives traffic when primary health check fails |

## Failover model

Route53 health checks monitor the primary cell endpoint.

When cell-a is unhealthy, Route53 directs traffic to cell-b.

This is a DNS-level failover model. It is simple and visible, but it is not instant. DNS cache behavior must be considered.

## GitOps model

The same application is deployed to both clusters using Argo CD ApplicationSet.

Each cluster receives its own overlay:

```text
cell-a cluster -> apps/overlays/cell-a
cell-b cluster -> apps/overlays/cell-b
```

Each overlay injects cell-specific metadata into the workload.

## Failure simulation

Use the runbook:

```text
runbooks/simulate-cell-failover.md
```

The simulation drains or breaks the cell-a ingress path, verifies that Route53 health check fails, then confirms traffic resolves to cell-b.

## Production considerations

Before production use:

- use real EKS modules
- configure remote Terraform state
- create real Route53 health checks
- use short but safe DNS TTLs
- define cell drain and restore runbooks
- ensure app data model supports failover
- add synthetic checks per cell
- add observability labels for cell, cluster, region, and route version
- test failback separately from failover

## References

- `experiments/cell-based/kubernetes-cell-implementation.md`
- `experiments/cell-based/infra-gitops-structure.md`
