# Infrastructure and GitOps repository structure

This document maps the Kubernetes cell implementation blueprint into a practical repository structure.

The structure separates infrastructure provisioning, platform components, application deployment, cell overlays, policy, and operational runbooks.

## Goals

- Keep infrastructure and application deployment concerns separated.
- Make cells repeatable through shared base configuration.
- Allow controlled per-cell customization through overlays.
- Support progressive rollout by cell.
- Make routing, observability, policy, and ownership explicit.
- Avoid manual configuration drift across cells.

## Repository model

A production organization may use one repository or multiple repositories.

The recommended starting point is a single architecture repository with clear directories. This keeps the implementation understandable while the operating model is still being proven.

```text
infraforge/
  docs/
  experiments/
  infra/
  gitops/
  platform/
  apps/
  policies/
  runbooks/
  scripts/
```

## Top-level structure

```text
infraforge/
├── docs/
│   └── style.md
├── experiments/
│   └── cell-based/
├── infra/
│   ├── accounts/
│   ├── network/
│   ├── eks/
│   ├── dns/
│   ├── security/
│   └── observability/
├── gitops/
│   ├── clusters/
│   ├── cells/
│   ├── environments/
│   └── argocd/
├── platform/
│   ├── ingress/
│   ├── observability/
│   ├── secrets/
│   ├── policy/
│   └── service-mesh/
├── apps/
│   ├── base/
│   └── overlays/
├── policies/
│   ├── kubernetes/
│   ├── terraform/
│   └── ci/
├── runbooks/
│   └── cell-operations/
└── scripts/
    ├── validate/
    └── generators/
```

## Infrastructure layer

The `infra/` directory owns cloud resources that exist below Kubernetes.

```text
infra/
├── accounts/
│   ├── README.md
│   └── cell-account-model.md
├── network/
│   ├── vpc/
│   ├── subnets/
│   ├── security-groups/
│   └── transit/
├── eks/
│   ├── modules/
│   │   ├── cluster/
│   │   ├── node-groups/
│   │   └── addons/
│   └── cells/
│       ├── cell-a/
│       ├── cell-b/
│       └── cell-c/
├── dns/
│   ├── route53/
│   └── routing-records/
├── security/
│   ├── iam/
│   ├── kms/
│   └── secrets-manager/
└── observability/
    ├── cloudwatch/
    ├── log-archive/
    └── splunk-forwarding/
```

### Infrastructure ownership

| Directory | Responsibility |
|---|---|
| `infra/accounts` | account model and isolation boundaries |
| `infra/network` | VPC, subnet, routing, and connectivity design |
| `infra/eks` | EKS clusters, node groups, and add-ons |
| `infra/dns` | Route53 records and routing primitives |
| `infra/security` | IAM, KMS, and secrets foundation |
| `infra/observability` | cloud-level telemetry and log archive plumbing |

## GitOps layer

The `gitops/` directory owns desired state for clusters, cells, and environments.

```text
gitops/
├── argocd/
│   ├── projects/
│   ├── applicationsets/
│   └── app-of-apps/
├── clusters/
│   ├── cell-a-cluster/
│   ├── cell-b-cluster/
│   └── cell-c-cluster/
├── cells/
│   ├── base/
│   ├── cell-a/
│   ├── cell-b/
│   └── cell-c/
└── environments/
    ├── dev/
    ├── staging/
    └── prod/
```

### GitOps ownership

| Directory | Responsibility |
|---|---|
| `gitops/argocd` | Argo CD projects, ApplicationSets, and app-of-apps definitions |
| `gitops/clusters` | cluster registration and cluster-specific platform configuration |
| `gitops/cells` | shared cell base and per-cell overlays |
| `gitops/environments` | environment-level composition and rollout ordering |

## Cell overlay model

Each cell inherits from a shared base and adds local configuration.

```text
gitops/cells/
├── base/
│   ├── kustomization.yaml
│   ├── namespace.yaml
│   ├── labels.yaml
│   ├── resource-quotas.yaml
│   ├── network-policies.yaml
│   └── observability-labels.yaml
├── cell-a/
│   ├── kustomization.yaml
│   ├── cell-config.yaml
│   ├── ingress-values.yaml
│   ├── capacity.yaml
│   └── alerts.yaml
└── cell-b/
    ├── kustomization.yaml
    ├── cell-config.yaml
    ├── ingress-values.yaml
    ├── capacity.yaml
    └── alerts.yaml
```

### Required cell metadata

Each cell should define a small contract.

```yaml
cell_id: cell-a
region: us-west-2
environment: prod
routing_key: tenant-group-a
cluster_name: prod-cell-a
owner: platform-team
```

This metadata should be applied consistently to workloads, routing rules, logs, metrics, traces, alerts, and runbooks.

## Platform layer

The `platform/` directory owns reusable platform capabilities installed into clusters or cells.

```text
platform/
├── ingress/
│   ├── aws-load-balancer-controller/
│   ├── gateway-api/
│   └── external-dns/
├── observability/
│   ├── fluent-bit/
│   ├── opentelemetry-collector/
│   ├── prometheus/
│   └── splunk-forwarder/
├── secrets/
│   └── external-secrets-operator/
├── policy/
│   ├── kyverno/
│   └── opa-gatekeeper/
└── service-mesh/
    ├── istio/
    └── envoy-gateway/
```

Platform components should be installed through GitOps, not by manual cluster commands.

## Application layer

The `apps/` directory owns workload definitions.

```text
apps/
├── base/
│   ├── api-service/
│   ├── worker-service/
│   └── frontend-service/
└── overlays/
    ├── cell-a/
    │   ├── api-service/
    │   ├── worker-service/
    │   └── frontend-service/
    └── cell-b/
        ├── api-service/
        ├── worker-service/
        └── frontend-service/
```

Application overlays should only contain cell-specific differences.

Examples:

- replica count
- resource requests and limits
- feature flags
- routing annotations
- local dependency endpoints
- alert thresholds

## Routing configuration

Routing configuration should be versioned and reviewed.

```text
gitops/cells/cell-a/ingress-values.yaml
gitops/cells/cell-b/ingress-values.yaml
infra/dns/routing-records/prod.yaml
platform/ingress/gateway-api/routes/
```

Routing rules must include enough metadata to understand the decision path.

Recommended fields:

```yaml
route_id: tenant-a-primary
cell_id: cell-a
routing_key: tenant-group-a
priority: 100
failover_target: cell-b
rule_version: 2026-04-30.1
```

## Observability configuration

Observability configuration must enforce cell metadata.

```text
platform/observability/
├── fluent-bit/
├── opentelemetry-collector/
├── prometheus/
└── splunk-forwarder/

gitops/cells/cell-a/alerts.yaml
gitops/cells/cell-b/alerts.yaml
```

Required labels:

```yaml
cell_id: cell-a
cluster_name: prod-cell-a
region: us-west-2
environment: prod
service: api-service
```

No workload should be considered production-ready unless its logs, metrics, and traces include cell identity.

## Policy configuration

Policies should prevent drift and enforce the cell contract.

```text
policies/
├── kubernetes/
│   ├── require-cell-labels.yaml
│   ├── require-resource-limits.yaml
│   ├── block-privileged-pods.yaml
│   └── restrict-public-ingress.yaml
├── terraform/
│   ├── require-tags.rego
│   └── restrict-open-security-groups.rego
└── ci/
    ├── markdown-style.sh
    └── no-em-dash.sh
```

Example policy requirements:

- every namespace must include `cell_id`
- every workload must include owner metadata
- every container must define resource requests and limits
- public ingress must be explicitly approved
- production workloads must use approved registries

## CI and validation flow

Every pull request should validate both infrastructure and GitOps configuration.

```text
pull request
  |
  +-- markdown lint
  +-- policy checks
  +-- terraform fmt
  +-- terraform validate
  +-- kustomize build
  +-- helm template
  +-- conftest / policy tests
  +-- dry-run apply
```

Recommended validation scripts:

```text
scripts/validate/
├── docs-style.sh
├── terraform.sh
├── kustomize.sh
├── helm.sh
├── policies.sh
└── cell-contract.sh
```

## Deployment flow

```text
Developer change
      |
      v
Pull request
      |
      v
CI validation
      |
      v
Merge to main
      |
      v
Argo CD detects change
      |
      v
Sync to canary cell
      |
      v
Health checks pass
      |
      v
Progress to additional cells
```

## Progressive rollout model

```text
cell-dev
  -> cell-canary
  -> prod-cell-a
  -> prod-cell-b
  -> prod-cell-c
```

Rollout should stop when any of these regress:

- error rate
- latency
- pod readiness
- queue depth
- ingress health
- synthetic checks
- alert volume

## Runbook structure

```text
runbooks/
└── cell-operations/
    ├── drain-cell.md
    ├── restore-cell.md
    ├── rollback-cell.md
    ├── onboard-cell.md
    ├── retire-cell.md
    ├── compare-cell-health.md
    └── validate-routing-change.md
```

Each runbook should include:

- purpose
- when to use it
- prerequisites
- steps
- validation
- rollback
- risks

## Mapping to blueprint phases

| Blueprint phase | Repository location |
|---|---|
| Define the cell contract | `gitops/cells/base`, `docs`, `policies/kubernetes` |
| Build one non-production cell | `infra/eks/cells/cell-dev`, `gitops/cells/cell-dev` |
| Build canary production cell | `infra/eks/cells/cell-canary`, `gitops/cells/cell-canary` |
| Expand to multiple cells | `infra/eks/cells`, `gitops/cells`, `apps/overlays` |
| Automate fleet management | `scripts/validate`, `policies`, `gitops/argocd/applicationsets` |

## Minimal first commit structure

Start with this small structure before creating many cells.

```text
infraforge/
├── infra/
│   └── eks/
│       └── cells/
│           └── cell-dev/
├── gitops/
│   └── cells/
│       ├── base/
│       └── cell-dev/
├── platform/
│   ├── ingress/
│   └── observability/
├── policies/
│   └── kubernetes/
├── runbooks/
│   └── cell-operations/
└── scripts/
    └── validate/
```

## Operating rule

Do not add a new cell until these are true:

- the cell contract is documented
- routing rules are versioned
- telemetry includes cell metadata
- rollback is tested
- drift detection is enabled
- ownership is clear

## References

- [`kubernetes-cell-implementation.md`](./kubernetes-cell-implementation.md)
- [`rfc.md`](./rfc.md)
- [`engineering-discovery.md`](./engineering-discovery.md)
