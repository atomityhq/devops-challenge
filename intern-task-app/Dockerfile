FROM python:3.12-slim
ENV PORT=8080

RUN useradd --uid 10001 app

WORKDIR /app
COPY app/app.py .

USER 10001
STOPSIGNAL SIGINT
CMD ["python", "app.py"]