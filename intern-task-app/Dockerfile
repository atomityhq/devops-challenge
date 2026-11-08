# The app is stdlib-only Python, so there is nothing to compile or install:
# a multi-stage build would have nothing to put in the builder stage.
# python:3.12-slim (Debian) is the smallest official image that still ships
# a normal glibc userland; alpine would save a few MB but swaps in musl for
# no real gain here.
FROM python:3.12-slim

# Unbuffered stdout so the "listening on ..." line shows up in `kubectl logs`
# immediately; no .pyc files since the container filesystem is throwaway.
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PORT=8080

# Run as a fixed, numeric non-root UID so Kubernetes can verify
# `runAsNonRoot: true` without having to resolve a username.
RUN groupadd --system --gid 10001 app \
 && useradd --system --uid 10001 --gid app --no-create-home --shell /usr/sbin/nologin app

WORKDIR /app
COPY --chown=root:root app/app.py .

USER 10001:10001

# 8080 rather than the app's default 5000: unprivileged, conventional, and it
# matches the "run directly" example in the README. The Deployment, probes and
# Service all target this port.
EXPOSE 8080

# Python runs as PID 1 here. PID 1 ignores SIGTERM unless it installs a
# handler, and the app doesn't, so a plain stop would hang until the 30s
# grace period ends and the runtime SIGKILLs it. Python *does* handle SIGINT
# (KeyboardInterrupt), so ask the runtime to send that instead.
STOPSIGNAL SIGINT

# Exec form: python is PID 1 and receives the stop signal directly.
CMD ["python", "app.py"]
