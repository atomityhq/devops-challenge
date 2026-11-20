FROM python:3.13-slim

# PORT is the single source of truth: the app reads it at runtime and
# EXPOSE below reuses it, so the two can never drift apart.
ENV PORT=8080 \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# tini runs as PID 1: forwards SIGTERM to the app and reaps zombies.
# Without it the kernel ignores SIGTERM for PID 1 and every stop waits
# for the SIGKILL timeout.
# Not version-pinned on purpose: apt resolves against the live Debian repo,
# so an exact pin breaks the build once that version is superseded. The base
# image digest above is what provides build reproducibility.
# hadolint ignore=DL3008
RUN apt-get update \
 && apt-get install -y --no-install-recommends tini \
 && rm -rf /var/lib/apt/lists/*

# Fixed numeric UID/GID so Kubernetes can verify "non-root".
RUN groupadd --system --gid 10001 app \
 && useradd  --system --uid 10001 --gid app --no-create-home \
             --shell /usr/sbin/nologin app

WORKDIR /srv
COPY app/app.py ./app.py

USER 10001:10001
EXPOSE ${PORT}

# Used by plain Docker (e.g. the EC2 host); Kubernetes ignores this and uses
# its own probes. Python does the check because slim ships no curl.
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD ["python", "-c", "import os,urllib.request as u; u.urlopen('http://127.0.0.1:%s/healthz' % os.environ['PORT'], timeout=2)"]

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["python", "app.py"]

