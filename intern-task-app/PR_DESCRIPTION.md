## Summary

- Add a container image for the dependency-free Python HTTP service.
- Add a Kubernetes Deployment with readiness and liveness probes.
- Add a ClusterIP Service that exposes port 80 and targets the app on port 8080.

## Design decisions

- Use `python:3.13-slim` to keep the runtime image smaller than the full Python image.
- Set `PORT=8080` consistently in the image and Deployment.
- Use `IfNotPresent` because the image is built locally and loaded into Kind without a registry.
- Run as UID/GID 10001, use a read-only root filesystem, drop all capabilities, and disable privilege escalation.
- Add conservative resource requests and limits.

## Verification

Run from `intern-task-app/`:

```sh
docker build -t intern-task-app:local .
kind create cluster --name intern-task
kind load docker-image intern-task-app:local --name intern-task
kubectl apply -f k8s/
kubectl rollout status deployment/intern-task-app --timeout=60s
kubectl port-forward svc/intern-task-app 8080:80
```

In another terminal:

```sh
curl -sf localhost:8080/healthz
curl -sf localhost:8080/
```

Expected responses: `ok` and `hello from intern-task`.

NOte:
If you don't have kind. you can install it using the below instructions

```sh
# Confirm your architecture
uname -m

# Download the AMD64 binary (if the output above is x86_64)
curl -L --connect-timeout 15 \
  -o kind \
  https://github.com/kubernetes-sigs/kind/releases/download/v0.33.0/kind-linux-amd64

# Install it
chmod +x kind
sudo mv kind /usr/local/bin/kind

# Verify
kind version
```

Tools I used:
- WSL
- DOCKER DESKTOP
- KUBERNETES