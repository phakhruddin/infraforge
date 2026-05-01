# Kubernetes cell implementation blueprint

This document describes an end-to-end blueprint for implementing a cell-based architecture on Kubernetes using AWS and EKS.

The blueprint focuses on engineering decisions, operating boundaries, routing, deployment, observability, security, and failure handling.

## Goals

- Reduce blast radius by isolating workloads into cells.
- Support controlled rollout by cell.
- Make routing decisions explicit and observable.
- Keep cell configuration consistent through GitOps.
- Preserve centralized governance without creating runtime coupling.
- Provide clear operational ownership for each cell.

## Non-goals

- This blueprint does not require every cell to be a separate AWS account.
- This blueprint does not require every service to be duplicated in every cell.
- This blueprint does not assume service mesh is mandatory.
- This blueprint does not remove the need for shared platform services.

## Reference architecture

```text
                            Users / Clients
                                  |
                                  v
                           Route53 / DNS
                                  |
                                  v
                    CloudFront / Global Accelerator
                                  |
                                  v
                         Regional ALB / NLB
                                  |
                +-----------------+-----------------+
                |                                   |
                v                                   v
          EKS Cell A                            EKS Cell B
    +--------------------+              +--------------------+
    | Ingress / Gateway  |              | Ingress / Gateway  |
    | Workloads          |              | Workloads          |
    | Local telemetry    |              | Local telemetry    |
    | Local policies     |              | Local policies     |
    +---------+----------+              +---------+----------+
              |                                   |
              v                                   v
       Local data / queues                 Local data / queues
              |                                   |
              +-----------------+-----------------+
                                |
                                v
                    Global observability layer
```

## Cell boundary model

A cell boundary should reflect a meaningful operational failure boundary.

Common boundary choices:

- tenant group
- geography
- workload class
- risk tier
- shard key
- compliance domain

The boundary should answer this question:

```text
What should be allowed to fail independently?
```

## AWS account and VPC model

### Option 1: One AWS account, multiple EKS clusters

Use when the platform is still proving the cell model.

Benefits:

- simpler account management
- lower governance overhead
- easier shared observability setup

Limitations:

- weaker hard isolation
- shared account quotas
- shared blast radius for IAM mistakes

### Option 2: AWS account per cell group

Use when stronger isolation is required.

Benefits:

- better quota isolation
- stronger IAM boundary
- clearer cost allocation

Limitations:

- more account vending automation
- more cross-account networking
- more governance overhead

### Option 3: AWS account per cell

Use only for strict isolation requirements.

Benefits:

- strongest boundary
- clean ownership
- clean cost allocation

Limitations:

- high operational overhead
- more complex deployment and observability
- requires mature platform automation

## EKS cluster model

### Cluster-per-cell

```text
cell-a = EKS cluster A
cell-b = EKS cluster B
cell-c = EKS cluster C
```

Use when cells require strong failure isolation.

Recommended baseline components per cluster:

- AWS Load Balancer Controller
- ExternalDNS or managed DNS workflow
- cert-manager or AWS Certificate Manager integration
- metrics collection
- log collection
- policy controller
- secrets integration
- GitOps controller

### Namespace-per-cell

```text
shared EKS cluster
  namespace cell-a
  namespace cell-b
  namespace cell-c
```

Use when the cell model is being introduced gradually or when workloads do not require hard isolation.

Required controls:

- ResourceQuota
- LimitRange
- NetworkPolicy
- Pod Security Standards
- namespace-level RBAC
- per-cell labels and annotations

## Routing blueprint

Routing must be explicit, observable, and reversible.

### Global routing layer

Use Route53, CloudFront, or Global Accelerator to direct traffic to the correct region or regional ingress layer.

Responsibilities:

- regional failover
- latency-aware routing
- disaster recovery steering
- public entry point ownership

### Regional ingress layer

Use ALB, NLB, or Kubernetes Gateway API.

Responsibilities:

- terminate or pass through TLS
- route to cell ingress
- enforce gateway policy
- support canary or weighted routing

### Cell routing layer

Inside the region, route traffic to the correct cell based on one or more keys:

- tenant ID
- shard key
- account ID
- region
- workload type

Example routing flow:

```text
request arrives
  |
  v
extract routing key
  |
  v
lookup cell mapping
  |
  v
route to cell ingress
  |
  v
record routing decision
```

Routing metadata should be logged with every request.

Minimum fields:

- route ID
- cell ID
- tenant or shard key
- routing rule version
- target cluster
- failover status

## GitOps blueprint

Cells should be managed through a GitOps model.

```text
infraforge-config
  environments
    prod
      cells
        cell-a
        cell-b
        cell-c
  platform
    base
      ingress
      observability
      policy
      secrets
```

### Base and overlay model

Use a shared base with per-cell overlays.

```text
base configuration
  |
  +-- cell-a overlay
  +-- cell-b overlay
  +-- cell-c overlay
```

Base contains common platform components.

Cell overlay contains:

- cell ID
- region
- capacity settings
- routing metadata
- local service overrides
- alert thresholds

### Rollout order

Use progressive rollout by cell.

```text
cell-dev
  -> cell-canary
  -> cell-a
  -> cell-b
  -> remaining cells
```

Rollout should stop automatically on health regression.

Health checks should include:

- error rate
- latency
- pod readiness
- queue depth
- ingress failure rate
- synthetic checks

## Observability blueprint

Every signal must include cell identity.

Required labels:

- cell_id
- cluster_name
- region
- environment
- service
- workload
- tenant_group when applicable

### Logging

Logs should support both local debugging and global aggregation.

Pattern:

```text
Pod logs
  |
  v
Fluent Bit / sidecar / agent
  |
  v
Cell-local buffer
  |
  v
Central log platform
```

### Metrics

Metrics should support:

- per-cell health
- cross-cell comparison
- global fleet view
- capacity planning

Core metrics:

- request rate by cell
- error rate by cell
- latency by cell
- saturation by cell
- pod restart count by cell
- queue depth by cell
- routing failures by cell

### Tracing

Trace context should carry cell metadata.

Useful attributes:

- source cell
- target cell
- routing decision
- service dependency
- retry count

## Splunk integration pattern

For Splunk-style log ingestion, use cell-aware log enrichment.

```text
EKS workloads
  |
  v
log collector
  |
  v
metadata enrichment
  |
  v
buffer or forwarder
  |
  v
Splunk ingestion endpoint
  |
  v
index by service, environment, and cell
```

Recommended fields:

- cell_id
- cluster_name
- namespace
- pod
- container
- service
- environment
- sourcetype

Operational concern:

> Without cell metadata, cell-based systems become harder to debug than shared systems.

## Security blueprint

### Identity

Every workload should have a distinct identity.

Options:

- IAM Roles for Service Accounts
- SPIFFE or SPIRE
- service mesh identity
- Kubernetes service accounts with strict RBAC

### Network controls

Use layered controls:

- VPC segmentation
- security groups
- Kubernetes NetworkPolicy
- ingress gateway policy
- egress policy

### Secrets

Use managed secrets integration.

Options:

- AWS Secrets Manager
- AWS Systems Manager Parameter Store
- External Secrets Operator

Secrets must not be copied manually between cells.

### Policy

Use policy-as-code to prevent drift.

Examples:

- require cell labels
- block privileged pods
- require resource requests and limits
- restrict public ingress
- enforce approved container registries

## Data model

The safest cell model keeps data local to the cell.

Preferred:

```text
tenant A -> cell A -> local data store A
tenant B -> cell B -> local data store B
```

Avoid cross-cell writes unless the workflow is explicitly designed.

If global data is required, classify it as:

- control-plane data
- reference data
- replicated data
- operational telemetry

## Failure scenarios

### Cell failure

Expected behavior:

- traffic to affected cell is stopped or reduced
- other cells continue serving traffic
- alerts identify the cell as the failure boundary

### Bad deployment to one cell

Expected behavior:

- rollout stops
- affected cell is rolled back
- other cells remain unchanged

### Routing table error

Expected behavior:

- routing changes are versioned
- previous routing rules can be restored
- affected tenants or shards are identifiable

### Observability pipeline failure

Expected behavior:

- local buffers absorb short outages
- ingestion delay is visible
- critical alerts still fire from independent health checks

### Shared control-plane failure

Expected behavior:

- existing cell runtime continues
- new deployments or routing updates may pause
- data-plane requests do not require the control plane for every request

## Operational runbooks

Minimum runbooks:

- drain traffic from a cell
- restore traffic to a cell
- roll back one cell
- compare health across cells
- onboard a new cell
- retire a cell
- rotate credentials across cells
- validate routing table changes

## Readiness checklist

A cell is production-ready when:

- it is provisioned through automation
- it has unique cell identity
- routing to the cell is documented
- telemetry includes cell metadata
- dashboards show cell health
- alerts include cell ID
- GitOps sync is healthy
- policy checks pass
- rollback has been tested
- traffic drain has been tested

## Implementation sequence

### Phase 1: Define the cell contract

Document:

- cell ID
- ownership
- routing key
- capacity envelope
- required platform components
- telemetry requirements

### Phase 2: Build one non-production cell

Validate:

- provisioning
- deployment
- ingress
- telemetry
- policy
- rollback

### Phase 3: Build a canary production cell

Route limited traffic to the cell.

Observe:

- reliability
- cost
- operational burden
- deployment behavior

### Phase 4: Expand to multiple cells

Introduce additional cells only after the operating model is proven.

### Phase 5: Automate fleet management

Add:

- drift detection
- policy enforcement
- rollout orchestration
- capacity reporting
- cell inventory

## Decision checkpoints

Before expanding the model, answer:

- Is the cell boundary correct?
- Is the routing model reversible?
- Can engineers debug one cell quickly?
- Can the platform compare health across cells?
- Can one cell fail without platform-wide impact?
- Is the operational overhead acceptable?

## References

- [`rfc.md`](./rfc.md)
- [`engineering-discovery.md`](./engineering-discovery.md)
- [`kubernetes-discussion-notes.md`](./kubernetes-discussion-notes.md)
