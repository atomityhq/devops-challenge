FROM python:3.13-slim-bookworm

ENV PORT=5000 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1
WORKDIR /app
RUN groupadd --gid 10001 app && useradd --uid 10001 --gid app --no-create-home app
COPY --chown=10001:10001 app/app.py /app/app.py
USER 10001:10001
EXPOSE 5000
CMD ["python", "/app/app.py"]
