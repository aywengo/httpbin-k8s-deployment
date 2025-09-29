# httpbin-k8s-deployment
Test assestment

## Task
```
Create a Kubernetes deployment using the public Docker image kennethreitz/httpbin. Ensure the deployment is evenly distributed across the cluster. Follow Kubernetes, container, and security best practices. Keep the solution minimal and clean. Demonstrate that the container is up and running -- the method of verification is up to you. Please document your solution clearly. As a result, we want a public repo in any version control system.
```

## Breakdown: 
### Sclability
TODO:
[ ] Kubernetes deployemnts vs SteafulSet (or anything else)
[x] define resources limits and requests: CPU and memory
[ ] check if there is no shared state or other impediments for horizontal scaling
[ ] investigate if Horizontal Pod Autoscaler (HPA) is needed

### Security
TODO:
[ ] scan with Trivy
[ ] check Dockerfile
[ ] define securityContext
[ ] investigate if Network Policy is needed

### Platform
TODO:
[ ] prepare YAML of objects
[ ] wrap into Helm Chart
[ ] prepare demo in minikube with docs
  
