FROM python:3.12-slim

WORKDIR /app

RUN useradd --create-home --uid 10001 appuser

COPY app/app.py ./app.py

ENV PORT=8080

USER appuser

EXPOSE 8080

CMD ["python", "app.py"]