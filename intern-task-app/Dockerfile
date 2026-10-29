FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8080

RUN useradd --system --no-create-home --shell /usr/sbin/nologin appuser

WORKDIR /app

COPY --chown=appuser:appuser app/app.py ./app.py

USER appuser

EXPOSE 8080

CMD ["python", "-u", "app.py"]
