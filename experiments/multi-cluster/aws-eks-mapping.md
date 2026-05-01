# Multi-Cluster: AWS / EKS Mapping + Whiteboard

## Whiteboard Diagram

```text
           Route53
             |
   ---------------------
   |         |         |
Cluster A  Cluster B  Cluster C
(EKS)      (EKS)      (EKS)
   |         |         |
 Apps       Apps      Apps
```

## AWS Mapping

- Clusters: EKS per region or cell
- Routing: Route53, AWS Global Accelerator
- Networking: VPC per cluster or shared VPC
- CI/CD: ArgoCD, GitHub Actions

## Key Insight

Multi-cluster introduces fleet management problems more than compute problems.
