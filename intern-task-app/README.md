# intern-task-app

A containerized Python HTTP application deployed to Kubernetes using Docker
and kind. This implementation demonstrates container security, Kubernetes
workload management, health monitoring, and service discovery.

## Architecture

The application is packaged into a Docker image and deployed to a local
Kubernetes cluster using two replicas.

- **Application:** Dependency-free Python HTTP server.
- **Container image:** `intern-task-app:local`.
- **Base image:** `python:3.12-slim`.
- **Container port:** `8080`.
- **Kubernetes Deployment:** `intern-task-app`.
- **Replicas:** 2.
- **Kubernetes Service:** `intern-task-app`, ClusterIP, port `80`.
- **Health endpoint:** `/healthz`.

## Project structure

```text
intern-task-app/
├── app/
│   └── app.py
├── k8s/
│   ├── deployment.yaml
│   └── service.yaml
├── .dockerignore
├── Dockerfile
└── README.md
Docker implementation
Build the image from this directory:
docker build -t intern-task-app:local .


Run the application locally:
docker run --rm -p 8080:8080 -e PORT=8080 intern-task-app:local


In another terminal, verify the endpoints:
curl -i http://localhost:8080/healthz
curl -i http://localhost:8080/


Expected response bodies:
- /healthz: ok
- /: hello from intern-task
Container security and reliability
The Docker image includes the following measures:
- Uses the lightweight python:3.12-slim base image.
- Runs as a dedicated non-root user (UID/GID 10001).
- Disables Python bytecode generation.
- Enables unbuffered Python output for container logs.
- Includes a Docker health check against /healthz.
- Uses .dockerignore to exclude unnecessary files and local environment data.
Kubernetes deployment
This project uses kind for local Kubernetes deployment.
1. Create the cluster
kind create cluster --name intern-task


2. Load the local image
kind load docker-image intern-task-app:local --name intern-task


The image is loaded directly into the kind node because it is not published
to an external container registry.
3. Deploy the application
kubectl apply -f k8s/


4. Verify the rollout
kubectl rollout status deployment/intern-task-app --timeout=120s


5. Inspect Kubernetes resources
kubectl get deployments
kubectl get pods -o wide
kubectl get services
kubectl get endpoints intern-task-app


6. Access the application
Start port forwarding:
kubectl port-forward svc/intern-task-app 8080:80


In another terminal, test the application:
curl -i http://localhost:8080/healthz
curl -i http://localhost:8080/


Expected response bodies:
- /healthz: ok
- /: hello from intern-task
Stop port forwarding with Ctrl+C.
Kubernetes security and reliability
The Deployment includes:
- Two application replicas for basic workload availability.
- Readiness and liveness HTTP probes against /healthz.
- Non-root execution using UID/GID 10001.
- RuntimeDefault seccomp profile.
- Disabled privilege escalation.
- Read-only container root filesystem.
- All Linux capabilities dropped.
- CPU and memory requests and limits.
- imagePullPolicy: Never to use the image loaded into kind.
The Service selects pods using app: intern-task-app, exposes port 80,
and forwards traffic to the application's named container port http
(8080).
Verification results
The implementation was deployed and tested successfully on a local kind
cluster.

Verified results:
CheckResult
Docker image buildPassed
Container health checkHealthy
Container non-root userUID/GID 10001
kind image loadingPassed
Kubernetes Deployment2/2 available
Kubernetes pod status2 Running, 0 restarts
Readiness probeConfigured and passing
Liveness probeConfigured and passing
Kubernetes ServicePort 80
Service endpoints2 pod endpoints on port 8080
/healthz through ServiceHTTP 200
/ through ServiceHTTP 200

Troubleshooting
Inspect application pods:
kubectl get pods -l app=intern-task-app


Inspect pod events and health probes:
kubectl describe pods -l app=intern-task-app


Inspect application logs:
kubectl logs -l app=intern-task-app


Inspect Service endpoints:
kubectl get endpoints intern-task-app


Inspect recent cluster events:
kubectl get events --sort-by=.metadata.creationTimestamp


Cleanup
To remove the Kubernetes application resources:
kubectl delete -f k8s/


To delete the local kind cluster:
kind delete cluster --name intern-task
