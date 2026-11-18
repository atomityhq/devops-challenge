Intern Task App – DevOps Challenge

A lightweight Python HTTP application containerized with Docker and deployed to Kubernetes.

This project demonstrates containerization, Kubernetes deployment, service exposure, and application health monitoring.

Table of Contents
Project Overview
Technologies Used
Project Structure
Application Endpoints
Docker Configuration
Kubernetes Deployment
Deployment Instructions
Verification and Testing
Accessing the Application
Troubleshooting
Project Overview

The application is a simple, dependency-free Python HTTP server.

It is packaged into a Docker image using Python 3.12 Slim and deployed to a local Kubernetes cluster.

The deployment includes:

A Kubernetes Deployment managing one application replica.
A Kubernetes Service exposing the application internally.
Readiness and liveness probes using the /healthz endpoint.
A non-root user inside the Docker container.
Local Docker image usage without requiring an external container registry.
Technologies Used
Python 3.12 – Application runtime.
Docker – Application containerization.
Kubernetes – Container orchestration.
kubectl – Kubernetes cluster management.
kind – Local Kubernetes cluster option.
Project Structure
text
intern-task-app/
├── app/
│   └── app.py
├── k8s/
│   ├── deployment.yaml
│   └── service.yaml
├── Dockerfile
└── README.md

Application Endpoints

The application exposes two HTTP endpoints:

Endpoint	Description	Expected response
/	Application homepage	hello from intern-task
/healthz	Health check endpoint	ok

The application listens on port 5000 by default.

The listening port can be configured using the PORT environment variable.

Docker Configuration

The application uses the official python:3.12-slim base image.

The Dockerfile includes:

A lightweight Python base image.
A dedicated non-root user named appuser.
Port 5000 exposed for application traffic.
Application startup using Python.
Build the Docker image
bash
docker build -t intern-task-app:local .

Run the container locally
bash
docker run --rm -p 8080:5000 intern-task-app:local


Test the application:

bash
curl http://localhost:8080/
curl http://localhost:8080/healthz

Kubernetes Deployment

The application is deployed using two Kubernetes manifests.

Deployment

File: k8s/deployment.yaml

The Deployment:

Creates one application replica.
Uses the locally built Docker image.
Sets imagePullPolicy: Never.
Exposes container port 5000.
Configures readiness and liveness probes against /healthz.
Service

File: k8s/service.yaml

The Service:

Uses the ClusterIP service type.
Exposes port 80.
Routes traffic to application port 5000.
Selects application pods using the label app: intern-task-app.
Deployment Instructions

The following instructions use kind as an example local Kubernetes environment.

1. Build the Docker image
bash
docker build -t intern-task-app:local .

2. Create a local Kubernetes cluster
bash
kind create cluster --name intern-task


Skip this step if your cluster already exists.

3. Load the Docker image into kind
bash
kind load docker-image intern-task-app:local --name intern-task

4. Apply Kubernetes manifests
bash
kubectl apply -f k8s/

5. Check deployment status
bash
kubectl rollout status deployment/intern-task-app --timeout=60s

Verification and Testing

Check the running pods:

bash
kubectl get pods


Check the deployment:

bash
kubectl get deployments


Check the Kubernetes services:

bash
kubectl get services


Expected deployment status:

Desired replicas: 1
Available replicas: 1
Pod status: Running
Accessing the Application

The Kubernetes Service uses ClusterIP, so it is accessible internally within the cluster.

To access the application locally, use port forwarding:

bash
kubectl port-forward svc/intern-task-app 8080:80


Open another terminal and test:

bash
curl http://localhost:8080/


Expected response:

text
hello from intern-task


Test the health endpoint:

bash
curl http://localhost:8080/healthz


Expected response:

text
ok

Troubleshooting
Check pod status
bash
kubectl get pods

Inspect pod events
bash
kubectl describe pod <pod-name>

Check application logs
bash
kubectl logs deployment/intern-task-app

Check deployment status
bash
kubectl describe deployment intern-task-app

Check service configuration
bash
kubectl describe service intern-task-app

Conclusion

This project demonstrates the containerization and deployment of a Python application using Docker and Kubernetes.

It implements container security through a non-root user, application health monitoring through Kubernetes probes, and internal service discovery through a ClusterIP Service.

The application was deployed successfully to a local Kubernetes cluster, with its pod running and deployment available.

Project: Atomity DevOps Challenge
Application: intern-task-app
