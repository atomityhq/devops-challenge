# python:3.12-slim: the app is stdlib-only, so there is nothing to compile and
# no need for a build stage. slim (Debian) is a small, well-patched image that
# avoids Alpine/musl surprises; the image stays small without a multi-stage build.
FROM python:3.12-slim

# Unbuffered output so "listening on ..." and any crash trace show up in
# `docker logs` / `kubectl logs` immediately.
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PORT=5000

WORKDIR /app

# Run as an unprivileged user. A numeric UID (not a name) lets Kubernetes verify
# `runAsNonRoot: true` without having to resolve /etc/passwd.
RUN groupadd --system --gid 10001 app \
 && useradd --system --uid 10001 --gid app --no-create-home --shell /usr/sbin/nologin app

COPY --chown=app:app app/app.py ./app.py

USER 10001:10001

# Documentation only; the app binds to $PORT (default 5000, set above).
# Everything downstream (k8s containerPort/probes/Service, the Terraform
# security group and host firewall) is derived from or must match this line.
EXPOSE 5000

# Plain `docker run` health check (ignored by Kubernetes, which uses its probes).
# Uses the interpreter already in the image, so no curl/wget is needed.
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD ["python", "-c", "import os,urllib.request as u; u.urlopen('http://127.0.0.1:%s/healthz' % os.environ.get('PORT','5000'), timeout=2)"]

CMD ["python", "app.py"]
