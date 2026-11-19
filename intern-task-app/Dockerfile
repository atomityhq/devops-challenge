# Tag kept for readability; the digest is what actually pins the build.
FROM python:3.13-slim@sha256:e48f59cdba69a3cbd9ed2cf0f348d90d45a8d350d98134cf1070bc106ee9ed90

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PORT=8080

# tini: Python as PID 1 ignores SIGTERM, so without an init process every
# `docker stop` / pod termination waits out the full grace period, then SIGKILLs.
RUN apt-get update \
    && apt-get install -y --no-install-recommends tini \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd --system --gid 10001 app \
    && useradd --system --uid 10001 --gid app --no-create-home --shell /usr/sbin/nologin app

WORKDIR /app
# Root-owned and read-only: the runtime user can read its code but never modify it.
COPY --chmod=0444 app/app.py .

USER 10001:10001
EXPOSE 8080

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["python", "app.py"]