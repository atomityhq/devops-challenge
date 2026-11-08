# intern-task-app

`app/app.py` is a tiny, dependency-free Python HTTP service. The Dockerfile
packages it as a non-root container, and the Kubernetes manifests deploy it
behind a ClusterIP Service.

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

### Implementation choices

- **Deployment** named `intern-task-app`, pods labeled `app: intern-task-app`,
  with a readiness *and* liveness probe against `/healthz`.
- **Service** named `intern-task-app`, selecting those pods, exposing port
  `80` and routing it to wherever the app is actually listening.
- `python:3.12-slim` provides the Python runtime and standard library without
  the size of the full Python image. The app has no third-party dependencies,
  so a separate build stage would add complexity without a useful artifact.
- The image creates a fixed, unprivileged UID/GID and Kubernetes enforces the
  same identity. This avoids running the service as root.
- `imagePullPolicy: Never` is appropriate because the image is loaded into the
  local Minikube node and is not published to a registry.
- A startup probe allows the Python process up to 30 seconds to begin serving
  `/healthz`; readiness and liveness checks wait until startup succeeds.
  Readiness keeps an unready pod out of Service traffic. Liveness restarts the
  container after repeated failures. All probes check the actual HTTP app on
  port 5000.
- The Deployment listens on 5000 and the Service maps port 80 to that named
  container port.
- Everything should come up clean on a stock local cluster: no
  `ImagePullBackOff`, no failing probes, no manual patching after `apply`.

Nice to have, not required — if you want to show more: a non-root user in
the image, resource requests/limits, a multi-stage build. Mention in the PR
if you did any of this and why; we're not docking points for skipping it.

## Verifying it works

Run from this directory with Docker Desktop available to WSL Ubuntu and the
Minikube Docker driver configured:

```bash
docker build -t intern-task-app:local .
minikube start --driver=docker --profile=intern-task
minikube image load intern-task-app:local -p intern-task
kubectl apply -f k8s/
kubectl rollout status deployment/intern-task-app --timeout=60s

kubectl port-forward svc/intern-task-app 8080:80
```

In another terminal, run:

```bash
curl -sf localhost:8080/healthz
curl -sf localhost:8080/
```

Expected responses are `ok` and `hello from intern-task`. Also inspect the
pod status and events for image pull, restart, and probe errors. Do not report
runtime verification as successful until these commands have completed.

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

## CI and PR verification

GitHub Actions builds the Docker image and runs
`kubeconform -summary -strict k8s/` when a pull request changes files under
`intern-task-app/`. CI performs schema validation only; it does not deploy to
a Kubernetes cluster. Record the actual CI result and Minikube command output
in the PR description. Local runtime verification must be completed separately.
