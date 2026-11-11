
FROM python:3.12-slim

WORKDIR /app

RUN groupadd --system appgroup && \
    useradd --system --uid 10001 --gid appgroup \
    --no-create-home appuser

COPY --chown=appuser:appgroup app/app.py ./app.py

ENV PORT=8080

EXPOSE 8080

USER appuser

CMD ["python", "-u", "app.py"]
