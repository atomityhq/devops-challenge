# Container and Kubernetes solution

The app listens on TCP 5000. The Dockerfile, Deployment environment, named
container port, probes and Service target all agree. The Service exposes port 80.

## Decisions

- Python 3.13 slim Bookworm supplies the Python runtime without build tools.
  There are no third-party dependencies or compiled artifacts, so a multi-stage
  build would add complexity without removing a build toolchain.
- The process uses UID/GID 10001. Kubernetes additionally drops capabilities,
  disables privilege escalation and service-account token mounting, and uses a
  read-only root filesystem and the runtime's default seccomp profile.
- `imagePullPolicy: Never` expresses the local-only image requirement. Load
  `intern-task-app:local` into the cluster before applying the manifests.
- Readiness stops routing traffic to an unresponsive process. Liveness restarts
  it after repeated failed HTTP requests. Both call the running app's `/healthz`.
  This minimal endpoint tests HTTP responsiveness, not external dependencies.
- Requests are 50m CPU/32Mi memory; limits are 250m CPU/64Mi memory for this tiny
  standard-library HTTP service. These are starting values, not load-test results.

## Reproduce locally

From `intern-task-app/`, with Docker, kind and kubectl installed:

```bash
docker build -t intern-task-app:local .
kind create cluster --name atomity-intern
kind load docker-image intern-task-app:local --name atomity-intern
kubectl --context kind-atomity-intern apply -f k8s/
kubectl --context kind-atomity-intern rollout status deployment/intern-task-app --timeout=90s
kubectl --context kind-atomity-intern port-forward svc/intern-task-app 18081:80
```

In another terminal:

```bash
curl -fsS localhost:18081/healthz  # ok
curl -fsS localhost:18081/         # hello from intern-task
kubeconform -strict -summary k8s/
```

The port-forward runs until interrupted. After testing, optionally remove only
this test cluster with `kind delete cluster --name atomity-intern`.

## Additional checks

```bash
docker run --rm --entrypoint python intern-task-app:local -c 'import os; assert os.getuid() == 10001'
docker run --rm -p 127.0.0.1:18080:8080 -e PORT=8080 intern-task-app:local
# In another terminal: curl -fsS localhost:18080/healthz
```

A deliberate hang exercises the probes in the disposable cluster:

```bash
kubectl --context kind-atomity-intern exec deployment/intern-task-app -- python -c 'import socket,time; s=socket.create_connection(("127.0.0.1",5000)); s.sendall(b"GET / HTTP/1.1\r\n"); time.sleep(120)'
# Run the following in a separate terminal while the request is stalled:
kubectl --context kind-atomity-intern wait --for=condition=Ready=false pod -l app=intern-task-app --timeout=30s
kubectl --context kind-atomity-intern wait --for=condition=Ready pod -l app=intern-task-app --timeout=90s
kubectl --context kind-atomity-intern get pods
```

The given app uses a single-threaded HTTP server with no request timeout, so an
incomplete HTTP request blocks it. Probes recover it, but this is not a production
server or a substitute for request timeouts/concurrent request handling.

See the submission's verification record for observed results, rather than
treating these commands as evidence by themselves.
