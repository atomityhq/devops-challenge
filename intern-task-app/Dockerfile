
FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

COPY app/app.py ./app.py

RUN useradd --system --no-create-home appuser

USER appuser

ENV PORT=8080

EXPOSE 8080

CMD ["python", "app.py"]
