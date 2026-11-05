FROM python:3.12-slim

WORKDIR /app

COPY app/ ./app/

ENV PORT=5000

EXPOSE 5000

CMD ["python", "app/app.py"]