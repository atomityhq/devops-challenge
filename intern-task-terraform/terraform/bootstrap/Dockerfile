FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8080

WORKDIR /app

RUN groupadd --gid 10001 appuser && \
    useradd --uid 10001 --gid 10001 \
    --no-create-home --shell /usr/sbin/nologin appuser

COPY --chown=appuser:appuser app/ ./app/

USER 10001:10001

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s \
    --start-period=5s --retries=3 \
    CMD ["python", "-c", "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8080/healthz', timeout=2)"]

CMD ["python", "app/app.py"]
