##Phase 1 — Docker Containerization

#Implementation

    -Selected python:3.12-slim.

    -Configured Python environment variables.

    -Created a dedicated non-root application user.

    -Copied the application into the image.

    -Configured port 5000.

    -Used exec-form CMD to start the application.

#Verification

    -Built intern-task-app:local.

    -Started the container.

    -Verified the root and health endpoints.

##Phase 2 — Kubernetes Preparation

#Implementation

    -Prepared a local kind cluster.

    -Loaded the Docker image into the kind node.

    -Confirmed Kubernetes node readiness.

##Phase 3 — Kubernetes Deployment

#Implementation

    -Created the Deployment manifest.

    -Configured readiness and liveness probes.

    -Defined resource requests and limits.

    -Created a ClusterIP Service.

    -Connected Service port 80 to application port 5000.

##Phase 4 — Deployment Verification

#Verification results

    -Deployment availability: 1/1.

    -Pod readiness: 1/1.

    -Pod restarts: 0.

    -Service creation: successful.

    -Root HTTP endpoint: HTTP 200.
