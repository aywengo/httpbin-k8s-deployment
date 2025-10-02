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
[x] prepare demo in minikube with docs
  
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

## Test

### Prerequisites
- Minikube running locally (`minikube start`)
- Kubectl configured to point to Minikube (`kubectl config use-context minikube`)
- Helm v3 installed (`helm version`) for chart-based tests

### Test Steps (YAML)
- Adjust HPA limits in `../yaml/hpa.yaml` (`minReplicas`/`maxReplicas`) to match your test scenario
- Apply manifests: `kubectl apply -f ../yaml/`
- Confirm pods are ready: `kubectl get pods -l app=httpbin`
- Port-forward the service: `kubectl port-forward svc/httpbin 8080:80`
- Verify HTTP response: `curl http://localhost:8080/status/200`
- Scale up replicas: `kubectl scale deployment httpbin --replicas=4`
- Scale down replicas: `kubectl scale deployment httpbin --replicas=2`
- Clean up manifests: `kubectl delete -f ../yaml/`

### Test Steps (Helm)
- Install the chart: `helm upgrade --install httpbin ../helm`
- Confirm pods are ready: `kubectl get pods -l app=httpbin`
- Port-forward the service: `kubectl port-forward svc/httpbin 8080:80`
- Verify HTTP response: `curl http://localhost:8080/status/200`
- Scale up replicas: `helm upgrade httpbin ../helm --set replicaCount=4`
- Scale down replicas: `helm upgrade httpbin ../helm --set replicaCount=2`
- Tear down: `helm uninstall httpbin`

### Demonstrate Node Scaling & Pod Distribution
- Add a node: `minikube node add`
- Wait for scheduling: `kubectl get nodes`
- Scale deployment: `kubectl scale deployment httpbin --replicas=4`
- Check pod spread: `kubectl get pods -o wide -l app=httpbin`
- Remove a node: `minikube node delete --name <node-name>` (evicts pods)
- Watch rescheduling: `kubectl get pods -w -l app=httpbin`

## Reference Docs
- Kubernetes Deployment: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/
- Kubernetes Service: https://kubernetes.io/docs/concepts/services-networking/service/
- Horizontal Pod Autoscaler (HPA): https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/
- NetworkPolicy: https://kubernetes.io/docs/concepts/services-networking/network-policies/
- Helm Charts: https://helm.sh/docs/topics/charts/
