FROM python:3.12-slim

RUN useradd --create-home appuser

WORKDIR /app

COPY app/app.py .

ENV PORT=5000

EXPOSE 5000

USER appuser

CMD ["python", "app.py"]
