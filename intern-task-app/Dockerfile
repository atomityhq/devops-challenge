FROM python:3.12-slim

WORKDIR /app

ENV PORT=8080
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

COPY app/app.py ./app.py

RUN groupadd --gid 10001 appgroup && \
    useradd --uid 10001 --gid 10001 \
    --no-create-home --shell /usr/sbin/nologin appuser

USER appuser

EXPOSE 8080

CMD ["python", "app.py"]