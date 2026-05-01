# Zero Trust: AWS / EKS Mapping + Whiteboard

## Whiteboard Diagram

```text
User / Service
     |
     v
Identity Provider (OIDC / SAML)
     |
     v
API Gateway / ALB
     |
     v
Service Mesh (mTLS)
     |
     v
Kubernetes Services / Pods
```

## AWS Mapping

- Identity: IAM, OIDC, Cognito
- Auth: ALB OIDC, API Gateway
- Service identity: SPIFFE/SPIRE (optional)
- Encryption: TLS / mTLS (Istio)
- Policy: OPA / AWS IAM policies

## Key Insight

Zero trust is identity-first, not network-first.
