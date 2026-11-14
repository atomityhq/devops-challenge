# Pinned slim base: the app is stdlib-only, so no build stage is needed.
FROM python:3.12-slim

# Keep the listen port explicit so the probes and Service targetPort can match it.
ENV PORT=5000 \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# Run as an unprivileged user rather than root.
RUN useradd --system --uid 10001 --no-create-home appuser

WORKDIR /app
COPY app/ /app/

USER 10001
EXPOSE 5000

CMD ["python", "app.py"]
