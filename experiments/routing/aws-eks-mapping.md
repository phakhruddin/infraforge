# Routing: AWS / EKS Mapping + Whiteboard

## Whiteboard Diagram

```text
Client
  |
  v
Route53 (DNS)
  |
  v
CloudFront / Global LB
  |
  v
ALB / NLB (Ingress)
  |
  v
Kubernetes Gateway / Ingress
  |
  v
Service Mesh (Istio / Envoy)
  |
  v
Pods / Services
```

## AWS Mapping

- Global routing: Route53, CloudFront
- Regional routing: ALB / NLB
- Cluster ingress: AWS Load Balancer Controller
- Service routing: Kubernetes Service / Gateway API
- Internal routing: Service mesh (Istio, Envoy)

## Key Insight

Routing spans multiple layers. Problems often happen at boundaries between layers.
