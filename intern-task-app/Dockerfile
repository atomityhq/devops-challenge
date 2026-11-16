FROM python:3.12-slim

RUN useradd -m -u 10001 appuser

WORKDIR /app

COPY app/ .

USER appuser

ENV PORT=5000
EXPOSE 5000

CMD ["python", "-u", "app.py"]
