FROM python:3.13-slim

ENV PYTHONUNBUFFERED=1 \
    PORT=8080

# Numeric UID so Kubernetes can verify runAsNonRoot
RUN useradd --uid 10001 --no-create-home --shell /usr/sbin/nologin appuser

WORKDIR /app
COPY app/app.py .

USER 10001
EXPOSE 8080

CMD ["python", "app.py"]
