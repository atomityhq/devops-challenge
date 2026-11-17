# Start from an official image that already has Python installed.
# "3.12" pins the version so builds are repeatable.
# "slim" is a stripped-down Debian: ~150MB instead of ~1GB for the full image,
# because the app needs nothing but Python itself (no compilers, no libraries).
FROM python:3.12-slim

# Environment variables baked into the image:
#  PYTHONUNBUFFERED=1   print output appears in logs immediately
#  PYTHONDONTWRITEBYTECODE=1   Python won't write .pyc cache files,
#                              which lets us make the filesystem read-only later
#  PORT=8080            tells app.py which port to listen on
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PORT=8080

# Create a regular user. Containers run as root by default, which means
# a bug in the app could be exploited with root privileges.
# Fixed UID 10001 (a number) lets Kubernetes verify it's not root.
RUN useradd --system --uid 10001 --no-create-home --shell /usr/sbin/nologin app

# All following commands operate in /app (created if missing).
WORKDIR /app

# Copy app.py from your folder into the image.
# Path is relative to where you run `docker build` (the intern-task-app folder).
COPY app/app.py .

# From here on, everything (including the running app) is this user, not root.
USER 10001

# Documentation: "this image listens on 8080." It doesn't open anything by itself.
EXPOSE 8080

# When the container is told to stop, send SIGINT instead of SIGTERM.
# Explained in Step 4b.
STOPSIGNAL SIGINT

# The command run when a container starts.
# JSON-array form ("exec form") runs python directly, with no shell in between,
# so python receives stop signals itself.
CMD ["python", "app.py"]