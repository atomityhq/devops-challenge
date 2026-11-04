FROM python:3.12-slim

WORKDIR /app

RUN useradd --create-home --uid 10001 appuser

COPY --chown=appuser:appuser app/ ./app/

ENV PORT=8080

EXPOSE 8080

USER appuser

CMD ["python", "-u", "app/app.py"]
