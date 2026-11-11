# syntax=docker/dockerfile:1
#
# Single stage on purpose: the app is stdlib-only, so there is nothing to
# compile and a second stage would ship the same bytes. Base is -slim rather
# than -alpine because the app needs nothing from musl, and keeping glibc
# avoids a second CVE feed for zero size win.
FROM python:3.12-slim

# PORT is set here so the image, the manifest and the Service can never
# disagree about which port the process binds. The app itself would fall back
# to 5000 if this were absent.
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PORT=8080

# Numeric UID so Kubernetes can actually verify runAsNonRoot: true. A named
# user would leave the kubelet unable to confirm the container is non-root.
RUN useradd --uid 10001 --no-create-home --shell /usr/sbin/nologin appuser

WORKDIR /app
COPY app/app.py ./app/app.py

USER 10001

# Documentation only - it does not publish anything. The real contract above
# is ENV PORT.
EXPOSE 8080

CMD ["python", "app/app.py"]
