# Testing and Verification Guide

This document explains how to build, run, deploy, and verify `intern-task-app` using Docker and a local Kubernetes cluster with Kind.

It also documents the reasoning behind the implementation choices and provides reproducible commands for local testing.

## 1. Prerequisites

The following tools are required:

| Tool    | Purpose                                 |
| ------- | --------------------------------------- |
| Docker  | Build and run the application container |
| Kind    | Create a local Kubernetes cluster       |
| kubectl | Manage Kubernetes resources             |
| curl    | Test HTTP endpoints                     |

Verify that the required tools are installed:

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

The application reads its listening port from the `PORT` environment variable, defaulting to `5000` when no value is provided.

## 3. Docker Verification

### 3.1 Build the Docker Image

Build the application image locally:

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

The host exposes port `8080`, which forwards incoming traffic to container port `5000`.

### 3.3 Inspect the Running Container

Check the running container:

```bash
docker ps
```

Inspect the application logs:

```bash
docker logs intern-task-app-test
```

The application should report that it is listening on `0.0.0.0:5000`.

### 3.4 Test the HTTP Endpoints

Test the health endpoint:

```bash
curl -i http://localhost:8080/healthz
```

Test the application endpoint:

```bash
curl -i http://localhost:8080/
```

Expected response bodies:

```text
ok
hello from intern-task
```

Both endpoints should return HTTP `200 OK`.

### 3.5 Verify Runtime Port Configuration

The application also supports overriding its default listening port through the `PORT` environment variable.

Run the container with port `8080`:

```bash
docker run --rm \
  -p 8080:8080 \
  -e PORT=8080 \
  intern-task-app:local
```

Keep this terminal running and open another terminal to test the endpoint:

```bash
curl -i http://localhost:8080/healthz
```

This verifies that the application correctly reads the overridden `PORT` environment variable.

Note: `EXPOSE 5000` in the Dockerfile documents the default application port. It does not prevent the application from listening on another port when `PORT` is overridden.

### 3.6 Clean Up the Docker Container

Stop and remove the detached test container:

```bash
docker stop intern-task-app-test
docker rm intern-task-app-test
```

If the runtime port override test is still running, stop it using `Ctrl+C`.

## 4. Kubernetes Verification with Kind

### 4.1 Create a Local Kubernetes Cluster

Create a local Kind cluster:

```bash
kind create cluster --name intern-task
```

If a cluster with this name already exists, reuse it instead of creating another one. Ensure it is running before proceeding.

Verify the cluster:

```bash
kind get clusters
kubectl get nodes
```

The Kubernetes node should eventually report `Ready`.

### 4.2 Load the Local Docker Image

Kind runs Kubernetes nodes inside Docker containers. Therefore, the locally built Docker image must be loaded into the Kind cluster before deploying the application.

Load the image:

```bash
kind load docker-image intern-task-app:local --name intern-task
```

For the default single-node Kind cluster, the image can be inspected inside the control-plane container:

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

A successful rollout indicates that the Deployment has reached its desired available state.

### 4.4 Inspect Kubernetes Resources

Inspect the Pods:

```bash
kubectl get pods -o wide
```

Inspect the Deployment:

```bash
kubectl get deployments
```

Inspect the Service:

```bash
kubectl get services
```

Check the Service endpoints:

```bash
kubectl get endpoints intern-task-app
```

Inspect the Deployment configuration and probe settings:

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

This forwards local port `8080` to port `80` of the Kubernetes Service.

### 5.2 Test the HTTP Endpoints

Open another terminal and test the health endpoint:

```bash
curl -sf http://localhost:8080/healthz
```

Test the application endpoint:

```bash
curl -sf http://localhost:8080/
```

Expected responses:

```text
ok
hello from intern-task
```

These requests verify that traffic can travel through the Kubernetes Service to the application running inside the Pod.

### 5.3 Verify Pod Health

Inspect the Pod:

```bash
kubectl get pods
```

Inspect its details using the application label:

```bash
kubectl describe pods -l app=intern-task-app
```

The Pod should be `Running` and `Ready`, with successful readiness and liveness probes.

## 6. Implementation Decisions

### Base Image: `python:3.12-slim`

The slim Python image provides the required Python runtime while avoiding the additional footprint of the full Python image.

It is sufficient for this dependency-free application.

### Non-root User

A dedicated system user runs the application instead of root.

This follows the principle of least privilege and reduces the privileges available to the application process.

### Python Environment Variables

The Dockerfile defines the following environment variables:

- `PYTHONDONTWRITEBYTECODE=1` prevents unnecessary Python bytecode files from being generated.
- `PYTHONUNBUFFERED=1` allows application output to appear immediately in container logs.
- `PORT=5000` establishes the default application listening port.

### Image Pull Policy: `IfNotPresent`

The image is built locally and loaded into the Kind cluster.

`IfNotPresent` allows Kubernetes to use an image already available on the node without requiring a remote registry pull.

This is appropriate for the local image workflow required by the challenge.

### Deployment Replicas: One

The Deployment uses one replica because the application is a lightweight HTTP service and the challenge does not require horizontal scaling or high availability.

Additional replicas would consume more CPU and memory without providing a meaningful benefit for this workload.

The Deployment can be scaled later if traffic or availability requirements justify it.

### Readiness Probe

The readiness probe checks `/healthz` to determine whether the application is ready to receive traffic.

If the probe fails, Kubernetes marks the Pod as not ready and excludes it from normal Service traffic.

### Liveness Probe

The liveness probe also checks `/healthz`.

If the application repeatedly fails its liveness probe, Kubernetes can restart the affected container.

Although both probes use the same endpoint, they serve different purposes:

- Readiness determines whether the application should receive traffic.
- Liveness determines whether the application should be restarted.

For this simple application, `/healthz` verifies that the HTTP server can respond successfully. It is not intended to detect every possible application-level or external dependency failure.

### Kubernetes Service

The Service exposes port `80` and forwards traffic to the named container port `http`, which maps to application port `5000`.

Using a named `targetPort` makes the relationship between the Service and the container port explicit.

### Resource Requests and Limits

The Deployment defines CPU and memory requests and limits.

Requests declare the resources Kubernetes should account for when scheduling the container, while limits constrain its resource consumption.

## 7. Port Configuration Reference

| Component                       | Port |
| ------------------------------- | ---: |
| Python application default port | 5000 |
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

Delete the Kind cluster when it is no longer needed:

```bash
kind delete cluster --name intern-task
```

Remove the Docker image if it is no longer needed:

```bash
docker rmi intern-task-app:local
```
