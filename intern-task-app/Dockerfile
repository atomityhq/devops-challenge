FROM python:3.13-slim

# PORT is the single source of truth: the app reads it at runtime and
# EXPOSE below reuses it, so the two can never drift apart.
ENV PORT=8080 \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# Fixed numeric UID/GID so Kubernetes can verify "non-root".
RUN groupadd --system --gid 10001 app \
 && useradd  --system --uid 10001 --gid app --no-create-home \
             --shell /usr/sbin/nologin app

WORKDIR /srv
COPY app/app.py ./app.py

USER 10001:10001
EXPOSE ${PORT}
CMD ["python", "app.py"]