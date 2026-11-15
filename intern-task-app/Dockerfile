FROM python:3.12-slim

RUN useradd -m appuser

WORKDIR /app

COPY app/app.py .

USER appuser

ENV PORT=5000

EXPOSE 5000

CMD ["python", "app.py"]