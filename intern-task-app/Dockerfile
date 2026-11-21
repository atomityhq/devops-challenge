FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8080

WORKDIR /app

RUN useradd --system --uid 10001 --no-create-home appuser

COPY --chown=10001:10001 app/ ./app/

USER 10001:10001

EXPOSE 8080

CMD ["python", "app/app.py"]
