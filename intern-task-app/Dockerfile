FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8080

WORKDIR /app
RUN groupadd --system appgroup \
    && useradd --system --gid appgroup --home-dir /app appuser

#COPY --chown=appuser:appgroup app/ ./app/
COPY app/app.py .

USER appuser

EXPOSE 8080

CMD ["python", "app.py"]
