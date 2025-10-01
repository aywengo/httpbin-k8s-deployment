# httpbin-k8s-deployment
Test assestment

## Task
```text
Create a Kubernetes deployment using the public Docker image kennethreitz/httpbin.
Ensure the deployment is evenly distributed across the cluster.
Follow Kubernetes, container, and security best practices. Keep the solution minimal and clean.
Demonstrate that the container is up and running -- the method of verification is up to you.
Please document your solution clearly.
As a result, we want a public repo in any version control system.
```

## Breakdown: 
### Sclability
TODO:
- [x] Kubernetes deployemnts vs SteafulSet (or anything else)
- [x] define resources limits and requests: CPU and memory
- [x] deside topologySpreadConstraints or podAntiAffinity
- [x] check if there is no shared state or other impediments for horizontal scaling
- [x] investigate if Horizontal Pod Autoscaler (HPA) is needed

### Security
TODO:
- [ ] scan with Trivy
- [ ] check Dockerfile
- [x] define securityContext
- [x] investigate if Network Policy is needed

### Platform
TODO:
[x] prepare YAML of objects
[x] wrap into Helm Chart
[ ] prepare demo in minikube with docs
  
## Solution

### 1. Plain yaml usage
Plain yaml is a good way to deploy applications in Kubernetes. It's easy to understand and debug.

#### Requirements
- Kubernetes cluster with kubectl context
- create or choose namespace: `kubectl create namespace httpbin` or use existing namespace `kkubectl config set-context --current --namespace=httpbin`


#### Deployment only
```bash
kubectl apply -f yaml/deployment.yaml
```

Probes: the Deployment includes simple readiness and liveness probes hitting `/status/200` on port 80.

#### Expose service (for in-cluster access only)
```bash
kubectl apply -f yaml/service.yaml
```

#### Implement autoscaling
```bash
kubectl apply -f yaml/hpa.yaml
```

#### Define NetworkPolicy
```bash
kubectl apply -f yaml/netpol.yaml
```

#### All at once
```bash
kubectl apply -f yaml/*.yaml
```

#### Scaling manually
```bash
kubectl scale deployment httpbin --replicas=3
```

#### Delete all
```bash
kubectl delete -f yaml/*.yaml
```

#### Debugging
```bash
kubectl describe deployment httpbin
kubectl get deploy,po,svc
kubectl get hpa
kubectl get networkpolicy
```
Check probe status by describing a Pod:
```bash
kubectl describe pod -l app=httpbin
```

### 2. Helm Chart

Helm simplifies deployment, scaling, and management of applications in Kubernetes.

#### Requirements
- Helm v3
- Kubernetes cluster with kubectl context
- For autoscaling: metrics-server installed

#### Debugging
```bash
helm template httpbin ./helm
```

#### Minimal setup (deployment only)
Installs a single replica; HPA and NetworkPolicy disabled by default.

```bash
helm install httpbin ./helm
kubectl get deploy,po,svc
```

Probes: readiness and liveness probes are enabled by default and check `/status/200` on port 80.

Configure probes via values or flags, for example:
```bash
helm upgrade --install httpbin ./helm \
  --set readinessProbe.httpGet.path=/status/200 \
  --set readinessProbe.initialDelaySeconds=5 \
  --set livenessProbe.initialDelaySeconds=10
```

Uninstall:
```bash
helm uninstall httpbin
```

#### With autoscaling
```bash
helm upgrade --install httpbin ./helm \
  --set autoscaling.enabled=true \
  --set autoscaling.minReplicas=3 \
  --set autoscaling.maxReplicas=10 \
  --set autoscaling.targetCPUUtilizationPercentage=50
kubectl get hpa
```

#### With NetworkPolicy
```bash
helm upgrade --install httpbin ./helm \
  --set networkPolicy.enabled=true
kubectl get networkpolicy
```
