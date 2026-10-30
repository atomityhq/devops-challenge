
FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=5000

WORKDIR /app

RUN useradd --system --no-create-home appuser

COPY app/ ./app/

USER appuser

EXPOSE 5000

CMD ["python", "app/app.py"]
