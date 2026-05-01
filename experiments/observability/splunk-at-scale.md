# Splunk at Scale

This note captures practical observability architecture patterns for running Splunk-style log ingestion at large cloud scale.

The focus is not just Splunk as a product, but the platform problems around ingestion, routing, buffering, cost, reliability, and operational ownership.

## Problem Context

At large scale, observability becomes a distributed data platform.

The platform must handle:

- high-volume log ingestion
- bursty workloads
- noisy tenants
- Kubernetes pod churn
- EC2 fleet growth
- indexer capacity limits
- network and load balancer failures
- compliance and audit requirements
- cost control

A common mistake is treating observability as only a logging pipeline.

At scale, it becomes a reliability-critical system.

## High-Level Architecture

```text
Application Workloads
        |
        | logs / metrics / events
        v
+----------------------+        +----------------------+
| EC2 / VM Workloads   |        | Kubernetes Workloads |
| Universal Forwarder  |        | Sidecar / Agent      |
+----------+-----------+        +----------+-----------+
           |                               |
           +---------------+---------------+
                           |
                           v
                 +-------------------+
                 | Ingestion Layer   |
                 | NLB / HEC / HF    |
                 +---------+---------+
                           |
                           v
                 +-------------------+
                 | Parsing / Routing |
                 | Filtering / Queue |
                 +---------+---------+
                           |
                           v
                 +-------------------+
                 | Splunk Indexers   |
                 | Multi-AZ Cluster  |
                 +---------+---------+
                           |
                           v
                 +-------------------+
                 | Search Heads      |
                 | Dashboards / SLO  |
                 +-------------------+
```

## Kubernetes Ingestion Pattern

For Kubernetes workloads, the common pattern is to run a log forwarder close to the workload.

Options include:

- sidecar forwarder per pod
- DaemonSet collector per node
- Fluentd / Fluent Bit pipeline
- OpenTelemetry collector

The key design trade-off:

> Sidecars improve per-workload ownership but increase pod resource overhead. DaemonSets reduce duplication but centralize failure and configuration concerns.

## Burst Buffer Pattern

When Splunk indexers or HEC endpoints cannot keep up, a buffer layer protects the system.

A practical AWS pattern:

```text
Kubernetes / EC2 Logs
        |
        v
Fluentd / Agent
        |
        v
S3 Buffer Bucket
        |
        v
SQS Notification
        |
        v
Splunk Ingestion Worker / HEC Puller
        |
        v
Splunk Indexers
```

This helps during:

- ingestion spikes
- indexer maintenance
- network instability
- downstream throttling

The downside is added latency and more moving parts.

## Failure Modes

### 1. Indexer saturation

Symptoms:

- queue buildup
- delayed indexing
- search latency
- dropped events if buffers are exhausted

Mitigation:

- increase indexer capacity
- add ingestion filtering
- tune forwarder queues
- use S3/SQS buffering

### 2. Noisy tenant or workload

Symptoms:

- one application floods ingestion
- shared indexers become unstable
- alert noise increases

Mitigation:

- per-tenant quotas
- routing by source type
- index-level isolation
- pre-ingestion filtering

### 3. Broken parsing rules

Symptoms:

- wrong sourcetype
- timestamp errors
- duplicated events
- search results become unreliable

Mitigation:

- GitOps-managed parsing configs
- staged rollout
- test data validation
- rollback plan

### 4. Kubernetes pod churn

Symptoms:

- missing logs
- duplicated metadata
- short-lived workload visibility gaps

Mitigation:

- enrich logs with pod metadata
- standardize labels
- keep collection close to workload
- monitor agent health

## Cost Control

Splunk cost usually follows ingestion volume.

Cost control strategies:

- filter debug noise before ingestion
- route low-value logs to cheaper storage
- sample high-volume low-value events
- separate hot searchable data from cold archive
- enforce source-level ownership

The key principle:

> Not every log deserves to be indexed forever.

## Operational Model

A strong Splunk-at-scale platform needs:

- clear onboarding standards
- standard index naming
- source type ownership
- GitOps-managed alert and dashboard changes
- compliance review for production alerts
- capacity dashboards
- ingestion health SLOs

## AWS / EKS Mapping

| Concern | AWS / EKS Component |
|---|---|
| Kubernetes workload logs | EKS pods, sidecars, DaemonSets |
| EC2 logs | Splunk Universal Forwarder |
| Ingestion endpoint | NLB, ALB, Splunk HEC |
| Buffering | S3, SQS |
| Processing | Lambda, ECS worker, EC2 worker, Heavy Forwarder |
| Storage/indexing | Splunk Indexer Cluster on EC2/EBS |
| Search | Splunk Search Head Cluster |
| Secrets | AWS Secrets Manager, Kubernetes Secrets |
| Observability of pipeline | CloudWatch, Splunk internal indexes, dashboards |
| Automation | Terraform, CDK, GitHub Actions, Argo CD |
