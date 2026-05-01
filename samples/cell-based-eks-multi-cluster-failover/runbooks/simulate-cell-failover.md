# Simulate cell failover

This runbook demonstrates how to simulate a failure in the primary cell and observe traffic failover to the secondary cell.

## Preconditions

- Both clusters are running
- Applications are deployed to both cells
- Route53 records are configured
- Health checks are enabled

## Step 1: Verify baseline

Confirm traffic goes to primary cell

```bash
curl http://app.example.com
```

## Step 2: Break primary cell ingress

Options:

- scale ingress controller to zero
- remove ALB listener rule
- block traffic with security group

Example:

```bash
kubectl scale deployment ingress-controller -n kube-system --replicas=0
```

## Step 3: Wait for health check failure

Wait until Route53 marks the primary endpoint as unhealthy

## Step 4: Verify failover

```bash
curl http://app.example.com
```

Response should come from cell-b

## Step 5: Restore primary cell

Restore ingress controller

```bash
kubectl scale deployment ingress-controller -n kube-system --replicas=2
```

## Step 6: Validate failback behavior

Confirm traffic returns to primary cell after health check recovery

## Notes

- DNS failover is not instant due to caching
- use low TTL for testing
- production TTL should balance stability and responsiveness
