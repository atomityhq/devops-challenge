FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=5000

WORKDIR /app

RUN groupadd --system appgroup \
    && useradd --system --gid appgroup --no-create-home appuser

COPY --chown=appuser:appgroup app/app.py ./app.py

USER appuser

EXPOSE 5000

CMD ["python", "app.py"]
