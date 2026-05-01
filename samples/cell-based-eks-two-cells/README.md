# Cell-based EKS sample with Terraform, Argo CD, two cells, and routing

This sample provides a minimal working structure for a cell-based Kubernetes platform on AWS EKS.

It is intentionally small and readable. The goal is to show how Terraform, GitOps, application overlays, cell metadata, and routing configuration fit together.

## What this sample includes

```text
samples/cell-based-eks-two-cells/
├── README.md
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── providers.tf
│   └── cells.auto.tfvars.example
├── gitops/
│   ├── argocd/
│   │   └── applicationset-cells.yaml
│   ├── cells/
│   │   ├── base/
│   │   │   ├── kustomization.yaml
│   │   │   ├── namespace.yaml
│   │   │   ├── resource-quota.yaml
│   │   │   └── network-policy.yaml
│   │   ├── cell-a/
│   │   │   ├── kustomization.yaml
│   │   │   └── cell-config.yaml
│   │   └── cell-b/
│   │       ├── kustomization.yaml
│   │       └── cell-config.yaml
│   ├── apps/
│   │   ├── base/
│   │   │   ├── kustomization.yaml
│   │   │   ├── deployment.yaml
│   │   │   ├── service.yaml
│   │   │   └── configmap.yaml
│   │   └── overlays/
│   │       ├── cell-a/
│   │       │   ├── kustomization.yaml
│   │       │   └── patch-cell.yaml
│   │       └── cell-b/
│   │           ├── kustomization.yaml
│   │           └── patch-cell.yaml
│   └── routing/
│       ├── gateway.yaml
│       └── httproutes.yaml
└── scripts/
    └── validate.sh
```

## Architecture

```text
Client
  |
  v
Route53
  |
  v
AWS ALB or Gateway controller
  |
  v
Kubernetes Gateway
  |
  +-- /cell-a -> app in cell-a namespace
  |
  +-- /cell-b -> app in cell-b namespace
```

## Design intent

This sample uses two logical cells inside one EKS cluster.

That keeps the sample approachable while still demonstrating the operating model.

In production, the same pattern can expand to:

- one namespace per cell
- one EKS cluster per cell
- one AWS account per cell group
- one AWS account per cell

## Cell model

| Cell | Namespace | Routing path | Purpose |
|---|---|---|---|
| cell-a | cell-a | `/cell-a` | primary sample cell |
| cell-b | cell-b | `/cell-b` | second isolated sample cell |

Each cell has:

- unique namespace
- unique labels
- resource quota
- default network policy
- application overlay
- routing target

## Terraform layer

Terraform creates the AWS foundation.

The included Terraform is a skeleton designed to be completed with real module sources.

It defines:

- VPC placeholder
- EKS cluster placeholder
- cell metadata locals
- outputs consumed by GitOps or operators

## GitOps layer

Argo CD owns the desired Kubernetes state.

The sample includes:

- ApplicationSet for cell overlays
- base cell namespace controls
- per-cell configuration
- app base and overlays
- routing manifests

## Routing layer

The routing example uses Kubernetes Gateway API style resources.

Routes:

```text
/cell-a -> service in namespace cell-a
/cell-b -> service in namespace cell-b
```

This keeps routing visible, reviewable, and versioned in Git.

## Validation

Run local validation:

```bash
./samples/cell-based-eks-two-cells/scripts/validate.sh
```

The validation checks:

- no em dash character is present
- Kustomize files exist
- cell overlays exist
- routing manifests exist

## Production hardening checklist

Before using this pattern in production:

- replace Terraform placeholders with approved modules
- add remote state configuration
- add OIDC and IRSA
- add AWS Load Balancer Controller
- add ExternalDNS or managed DNS workflow
- add cert-manager or ACM integration
- enforce NetworkPolicy with a compatible CNI or policy engine
- add policy checks with Kyverno, Gatekeeper, or Conftest
- add observability labels to logs, metrics, and traces
- add progressive rollout automation
- add runbooks for drain, rollback, and restore

## References

- `experiments/cell-based/kubernetes-cell-implementation.md`
- `experiments/cell-based/infra-gitops-structure.md`
