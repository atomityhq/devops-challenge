# syntax=docker/dockerfile:1

# Single stage on purpose: app.py has no dependencies, so there is nothing to
# compile or prune — a builder stage would add complexity and save nothing.
FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Listen port — single source of truth. k8s/ manifests target it, and
# ../intern-task-terraform parses this exact line.
ENV PORT=8080

# Fixed numeric UID so Kubernetes `runAsNonRoot` can verify it without
# reading /etc/passwd.
RUN useradd --system --uid 10001 --no-create-home --shell /usr/sbin/nologin app

WORKDIR /app
COPY app/app.py .

USER 10001:10001
EXPOSE ${PORT}

CMD ["python", "app.py"]
