FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=5000

RUN groupadd --system --gid 10001 appuser && \
    useradd --system --uid 10001 --gid appuser --no-create-home --shell /sbin/nologin appuser

WORKDIR /app

COPY --chown=10001:10001 app/app.py ./app.py

USER 10001:10001

EXPOSE 5000

CMD ["python", "app.py"]
