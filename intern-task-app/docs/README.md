# Testing and Verification Guide

This document describes how to build, run, deploy, and verify `intern-task-app` using Docker and a local Kubernetes cluster with Kind.

It also documents the reasoning behind the implementation choices and provides reproducible commands for local testing.

## 1. Prerequisites

The following tools are required:

| Tool    | Purpose                                 |
| ------- | --------------------------------------- |
| Docker  | Build and run the application container |
| Kind    | Create a local Kubernetes cluster       |
| kubectl | Manage Kubernetes resources             |
| curl    | Test HTTP endpoints                     |

Run the following commands to verify your environment:

```bash
docker --version
kind --version
kubectl version --client
curl --version
```

All commands below assume the working directory is `intern-task-app/`.

## 2. Application Overview

The application is a dependency-free Python HTTP service.

It exposes two endpoints:

| Endpoint   | Expected response        | Purpose              |
| ---------- | ------------------------ | -------------------- |
| `/`        | `hello from intern-task` | Application response |
| `/healthz` | `ok`                     | Health check         |

The application reads its listening port from the `PORT` environment variable, defaulting to `5000`.

## 3. Docker Verification

### 3.1 Build the Docker Image

Build the image locally:

```bash
docker build -t intern-task-app:local .
```

Inspect the generated image:

```bash
docker images intern-task-app
```

### 3.2 Run the Container

Start the application using its default port:

```bash
docker run -d \
  --name intern-task-app-test \
  -p 8080:5000 \
  intern-task-app:local
```

The host exposes port `8080`, which forwards traffic to container port `5000`.

### 3.3 Inspect the Running Container

```bash
docker ps
```

Inspect the application logs:

```bash
docker logs intern-task-app-test
```

### 3.4 Test the HTTP Endpoints

```bash
curl -i http://localhost:8080/healthz
curl -i http://localhost:8080/
```

Expected response bodies:

```text
ok
hello from intern-task
```

### 3.5 Verify Runtime Port Configuration

The application also supports overriding its default port.

```bash
docker run --rm \
  -p 8080:8080 \
  -e PORT=8080 \
  intern-task-app:local
```

In another terminal:

```bash
curl -i http://localhost:8080/healthz
```

This verifies that the application correctly reads the `PORT` environment variable.

### 3.6 Clean Up the Docker Container

```bash
docker stop intern-task-app-test
docker rm intern-task-app-test
```

## 4. Kubernetes Verification with Kind

### 4.1 Create a Local Kubernetes Cluster

```bash
kind create cluster --name intern-task
```

Verify the cluster:

```bash
kind get clusters
kubectl get nodes
```

The Kubernetes node should eventually report `Ready`.

### 4.2 Load the Local Docker Image

Kind runs Kubernetes nodes inside containers. The locally built Docker image must be loaded into the Kind cluster.

```bash
kind load docker-image intern-task-app:local --name intern-task
```

Verify the image is available:

```bash
docker exec intern-task-control-plane \
  crictl images | grep intern-task-app
```

### 4.3 Deploy Kubernetes Resources

Apply the Deployment and Service manifests:

```bash
kubectl apply -f k8s/
```

Check the Deployment rollout:

```bash
kubectl rollout status deployment/intern-task-app --timeout=60s
```

### 4.4 Inspect Kubernetes Resources

Check the Pods:

```bash
kubectl get pods -o wide
```

Check the Deployment:

```bash
kubectl get deployments
```

Check the Service:

```bash
kubectl get services
```

Check the Service endpoints:

```bash
kubectl get endpoints intern-task-app
```

Inspect the Deployment configuration and probe status:

```bash
kubectl describe deployment intern-task-app
```

The expected result is a running and ready Pod, a successful Deployment rollout, and a Service with an assigned endpoint.

## 5. Kubernetes Application Testing

### 5.1 Forward the Service Port

Start port forwarding:

```bash
kubectl port-forward svc/intern-task-app 8080:80
```

Keep this terminal running.

### 5.2 Test the Endpoints

Open another terminal:

```bash
curl -sf http://localhost:8080/healthz
curl -sf http://localhost:8080/
```

Expected responses:

```text
ok
hello from intern-task
```

This verifies that requests can travel through the Kubernetes Service to the application running inside the Pod.

### 5.3 Verify Pod Health

```bash
kubectl get pods
kubectl describe pod <pod-name>
```

Check that the Pod is `Running` and `Ready`, and that the readiness and liveness probes are succeeding.

## 6. Implementation Decisions

### Base Image: `python:3.12-slim`

The slim Python image provides the required Python runtime while avoiding the additional footprint of the full Python image.

### Non-root User

A dedicated system user runs the application instead of root.

This follows the principle of least privilege and reduces the privileges available to the application process.

### Python Environment Variables

- `PYTHONDONTWRITEBYTECODE=1` prevents unnecessary Python bytecode files.
- `PYTHONUNBUFFERED=1` allows application output to appear immediately in container logs.
- `PORT=5000` establishes the default application listening port.

### Image Pull Policy: `IfNotPresent`

The image is built locally and loaded into Kind.

`IfNotPresent` allows Kubernetes to use an image already available on the node without requiring a remote registry pull.

### Readiness Probe

The readiness probe checks `/healthz` to determine whether the application is ready to receive traffic.

If the probe fails, Kubernetes marks the Pod as not ready and excludes it from normal Service traffic.

### Liveness Probe

The liveness probe also checks `/healthz`.

If the application repeatedly fails its liveness probe, Kubernetes can restart the affected container.

Both probes use the same endpoint, but serve different purposes.

### Kubernetes Service

The Service exposes port `80` and forwards traffic to the named container port `http`, which maps to application port `5000`.

Using a named target port makes the relationship between the Service and the container port explicit.

### Resource Requests and Limits

The Deployment defines CPU and memory requests and limits to declare resource expectations and constrain container resource consumption.

## 7. Port Configuration Reference

| Component                       | Port |
| ------------------------------- | ---: |
| Python application              | 5000 |
| Container port                  | 5000 |
| Kubernetes Service port         |   80 |
| Kubernetes Service target port  | 5000 |
| Local Docker host port          | 8080 |
| Local Kubernetes forwarded port | 8080 |

## 8. Cleanup

Stop any active port-forwarding process using `Ctrl+C`.

Delete the Kubernetes resources:

```bash
kubectl delete -f k8s/
```

Delete the Kind cluster:

```bash
kind delete cluster --name intern-task
```

Remove the Docker test image if it is no longer needed:

```bash
docker rmi intern-task-app:local
```
