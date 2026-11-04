# intern-task-app

`app/app.py` is a tiny, dependency-free Python HTTP service. There's no
Dockerfile and no Kubernetes manifests yet — that's the task.

## Your task

Fork this repo, add what's missing, and open a PR back against `main`.
Everything for this task lives under `intern-task-app/` — you don't need
to touch anything outside this folder:

- A `Dockerfile` that builds and runs the app.
- `k8s/deployment.yaml` and `k8s/service.yaml` that deploy it.

## Implementation Overview

This implementation containerizes the existing Python HTTP application and deploys it to a local Kubernetes cluster using Kind.

### Docker Configuration

The application is packaged using the official `python:3.14-slim` base image.

The Dockerfile:
- Sets `/app` as the working directory.
- Copies the application source into the image.
- Sets `PORT=8080` as the application listening port.
- Exposes port `8080`.
- Starts the application using Python.

The application listens on `0.0.0.0:8080` inside the container.

### Kubernetes Configuration

The application is deployed using two Kubernetes resources:

**Deployment**
- Name: `intern-task-app`
- Replicas: `1`
- Pod label: `app: intern-task-app`
- Container image: `intern-task-app:local`
- Image pull policy: `IfNotPresent`
- Container port: `8080`
- Readiness and liveness probes: HTTP GET `/healthz`

**Service**
- Name: `intern-task-app`
- Type: `ClusterIP`
- Service port: `80`
- Target port: `8080`
- Pod selector: `app: intern-task-app`

The Service routes traffic from port `80` to port `8080` on the application container.

### Design Decisions

- **Python slim image:** Uses a smaller Python base image rather than a full operating-system image.
- **Port configuration:** Sets the application port to `8080` and keeps the container, probes, and Service target port consistent.
- **IfNotPresent image policy:** Allows Kubernetes to use the locally loaded image without requiring a registry pull.
- **HTTP health probes:** Both probes check `/healthz` to monitor application readiness and container health.

### Local Deployment and Verification

The implementation was tested using Docker and a local Kind Kubernetes cluster.

Verification included:
- Building the Docker image successfully.
- Running the application directly in Docker.
- Confirming that `/healthz` returned HTTP `200 OK` with `ok`.
- Confirming that `/` returned HTTP `200 OK` with `hello from intern-task`.
- Loading the local image into the Kind cluster.
- Successfully deploying the Kubernetes resources.
- Confirming that the Deployment rolled out and the Pod became ready.
- Testing both application endpoints through the Kubernetes Service using port-forwarding.

### Cleanup

To delete the local Kind cluster after testing:

```bash
kind delete cluster --name intern-task
```

This removes the local Kubernetes cluster and its resources.

### The app, as given

- Reads its listen port from the `PORT` environment variable, defaulting to
  `5000` if unset. Whether you override that default in your Dockerfile is
  your call — just make sure everything downstream (container port, health
  probes, Service `targetPort`) agrees with whatever the app actually binds
  to at runtime.
- Serves `/healthz` (returns `200 ok`) and `/` (returns `200`, some text).

### Requirements

- **Deployment** named `intern-task-app`, pods labeled `app: intern-task-app`,
  with a readiness *and* liveness probe against `/healthz`.
- **Service** named `intern-task-app`, selecting those pods, exposing port
  `80` and routing it to wherever the app is actually listening.
- Set `imagePullPolicy` appropriately — this image only ever exists locally
  (built + `kind load`'d), there's no registry to pull from.
- Everything should come up clean on a stock local cluster: no
  `ImagePullBackOff`, no failing probes, no manual patching after `apply`.

Nice to have, not required — if you want to show more: a non-root user in
the image, resource requests/limits, a multi-stage build. Mention in the PR
if you did any of this and why; we're not docking points for skipping it.

## Verifying it works

Any local Kubernetes works here (`kind`, `k3d`, `minikube`, Docker Desktop's
built-in cluster). Using `kind`:

```bash
docker build -t intern-task-app:local .
kind create cluster --name intern-task
kind load docker-image intern-task-app:local --name intern-task
kubectl apply -f k8s/
kubectl rollout status deployment/intern-task-app --timeout=60s

kubectl port-forward svc/intern-task-app 8080:80 &
curl -sf localhost:8080/healthz   # expect: ok
curl -sf localhost:8080/          # expect: hello from intern-task
```

Run this (or your own equivalent) before opening the PR — don't rely on
the diff looking right by eye.

CI on your PR only checks that the Dockerfile builds and the k8s YAML is
schema-valid — it never spins up a cluster or deploys anything. Passing CI
is not the same as this actually working; the steps above are how you
actually know.

## What we're looking for in the PR

- The verification steps above passing is the baseline, not the bar. We're
  looking at how you made the choices in between: why that base image, why
  that `imagePullPolicy`, whether the probes would actually catch a real
  failure or just rubber-stamp whatever's running.
- Include what you ran to confirm it works in the PR description. We'll
  re-run it ourselves too, but show your work.
- A clear PR description and commits a reviewer could follow matter as much
  as the YAML being correct.

## Running the app directly (without Kubernetes)

```bash
docker build -t intern-task-app:local .
docker run --rm -p 8080:8080 -e PORT=8080 intern-task-app:local
curl localhost:8080/healthz
```
