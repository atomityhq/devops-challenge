FROM python:3.13-slim

ENV PYTHONUNBUFFERED=1 \
    PORT=8080

RUN useradd --system --uid 10001 --no-create-home app

WORKDIR /srv
COPY app/app.py .
RUN chmod 644 /srv/app.py

USER 10001
EXPOSE 8080
CMD ["python", "app.py"]

.dockerignore:

k8s
README.md
**/_pycache_
