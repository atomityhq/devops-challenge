
FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=5000

WORKDIR /app

COPY app/app.py ./app.py

RUN useradd --system --uid 10001 appuser

USER 10001:10001

EXPOSE 5000

CMD ["python", "-u", "app.py"]

