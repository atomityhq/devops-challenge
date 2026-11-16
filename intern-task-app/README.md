# intern-task-app

A lightweight Python HTTP application packaged with Docker and deployed to Kubernetes.

This repository contains the application along with the Docker and Kubernetes configurations required to run it locally.

## Project Structure

```text
intern-task-app/
├── app/
│   └── app.py
├── k8s/
│   ├── deployment.yaml
│   └── service.yaml
├── Dockerfile
└── README.md
```

## Application

The application is a simple HTTP server written in Python.

- `/` returns a basic welcome message.
- `/healthz` is used to check application health.
- The server listens on port `5000` by default.
- The listening port can be changed using the `PORT` environment variable.

## Docker

Build the image:

```bash
docker build -t intern-task-app:local .
```

Run the container:

```bash
docker run --rm -p 8080:5000 intern-task-app:local
```

Test the application:

```bash
curl http://localhost:8080/
curl http://localhost:8080/healthz
```

## Kubernetes Deployment

The application can be deployed to a local Kubernetes cluster using the manifests in `k8s/`.

### 1. Create a Kind cluster

```bash
kind create cluster --name intern-task
```

### 2. Build the image and load it into Kind

```bash
docker build -t intern-task-app:local .
kind load docker-image intern-task-app:local --name intern-task
```

### 3. Deploy the application

```bash
kubectl apply -f k8s/
```

### 4. Check deployment status

```bash
kubectl rollout status deployment/intern-task-app --timeout=60s
kubectl get pods
kubectl get svc
```

### 5. Access the application

Forward the Kubernetes Service to your local machine:

```bash
kubectl port-forward svc/intern-task-app 8080:80
```

In another terminal:

```bash
curl http://localhost:8080/
curl http://localhost:8080/healthz
```

Expected responses:

```text
hello from intern-task
ok
```

## Kubernetes Features

The deployment includes:

- Kubernetes Deployment for managing application replicas.
- Service for exposing the application within the cluster.
- Readiness probe to verify the application is ready to receive traffic.
- Liveness probe to detect application failures.
- Local image configuration to avoid pulling from an external registry.
- Resource requests and limits for container resource management.

## Cleanup

Remove the application:

```bash
kubectl delete -f k8s/
```

Delete the Kind cluster:

```bash
kind delete cluster --name intern-task
```
