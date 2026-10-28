FROM python:3.12-slim

ENV PORT=8080

WORKDIR /app

COPY app/app.py .

RUN useradd --system --no-create-home appuser \
    && chown appuser /app/app.py

USER appuser

EXPOSE 8080

CMD ["python", "-u", "app.py"]
