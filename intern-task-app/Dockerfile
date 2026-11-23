FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8080

RUN groupadd --gid 10001 appuser \
    && useradd --uid 10001 --gid 10001 --no-create-home \
       --shell /usr/sbin/nologin appuser

WORKDIR /app
COPY --chown=10001:10001 app/app.py ./app.py

USER 10001:10001
EXPOSE 8080

CMD ["python", "app.py"]