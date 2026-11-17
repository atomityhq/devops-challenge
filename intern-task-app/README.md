# intern-task-app

`app/app.py` is a tiny, dependency-free Python HTTP service. There's no
Dockerfile and no Kubernetes manifests yet — that's the task.

## Your task

Fork this repo, add what's missing, and open a PR back against `main`.
Everything for this task lives under `intern-task-app/` — you don't need
to touch anything outside this folder:

- A `Dockerfile` that builds and runs the app.
- `k8s/deployment.yaml` and `k8s/service.yaml` that deploy it.

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
## Implementation

### Docker

The application is containerized using `python:3.13-slim` to provide a lightweight Python runtime without additional application dependencies.

The Dockerfile creates a non root user (`appuser`) and runs the application with that user to reduce unnecessary privileges.

The application listens on port `5000` by default, configurable through the `PORT` environment variable.

### Kubernetes

The Kubernetes manifests include:

- A Deployment named `intern-task-app` with two replicas.
- Pod labels and Service selectors using `app: intern-task-app`.
- A ClusterIP Service exposing port `80` and forwarding traffic to container port `5000`.
- Readiness and liveness probes using the `/healthz` endpoint.
- CPU and memory requests and limits for predictable resource allocation.
- `imagePullPolicy: Never` because the image is built locally and is not published to a container registry.

The readiness probe controls whether a Pod receives Service traffic. The liveness probe restarts a container after repeated failed health checks. Both check HTTP availability, but the simple `/healthz` endpoint does not validate external dependencies.

### Local Verification - Docker Desktop Kubernetes

The application was tested using Docker Desktop's built in Kubernetes cluster.

From the `intern-task-app` directory:

```powershell
docker build -t intern-task-app:local .
kubectl apply -f k8s/
kubectl rollout status deployment/intern-task-app --timeout=60s
kubectl get pods -l app=intern-task-app
```

Forward the Service port:

```powershell
kubectl port-forward svc/intern-task-app 8080:80
```

In another terminal, verify the endpoints:

```powershell
curl.exe -f http://localhost:8080/healthz
curl.exe -f http://localhost:8080/
```

Expected responses:

- `/healthz` - `ok`
- `/` - `hello from intern-task`

### Troubleshooting and Improvements

During initial testing, one Pod restarted following repeated liveness probe timeouts.

The Python application originally used `HTTPServer`, which processes requests sequentially. It was changed to `ThreadingHTTPServer` to allow concurrent HTTP requests and reduce the possibility of health checks waiting behind other connections.

After rebuilding the Docker image and restarting the Deployment, both Pods remained ready with zero restarts during a five minute observation period. Both HTTP endpoints were also verified successfully through the Kubernetes Service.