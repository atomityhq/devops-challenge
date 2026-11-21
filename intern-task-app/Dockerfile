FROM python:3.13-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8080

WORKDIR /app

RUN addgroup --gid 10001 app && \
    adduser --disabled-password --gecos "" --uid 10001 --gid 10001 hamada

COPY --chown=10001:10001 app/app.py /app/app.py

EXPOSE 8080

USER hamada

CMD ["python", "app.py"]

