# The app only uses the Python standard library, so there is nothing to
# compile or install: a multi-stage build would add complexity for no gain.
FROM python:3.12-slim
 
# No .pyc files (read-only root filesystem friendly), unbuffered logs.
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8080
 
# Dedicated unprivileged user with a NUMERIC uid, so Kubernetes can verify
# `runAsNonRoot: true` (it cannot resolve user names).
RUN useradd --system --uid 10001 --no-create-home --shell /usr/sbin/nologin app
 
WORKDIR /srv
COPY app/app.py .
 
USER 10001:10001
EXPOSE 8080
 
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD python -c "import os,urllib.request; urllib.request.urlopen('http://127.0.0.1:%s/healthz' % os.environ.get('PORT','8080'), timeout=2)" || exit 1
 
CMD ["python", "app.py"]