# Python's slim Debian image provides the interpreter and standard library
# this dependency-free app needs, without the larger general-purpose image.
FROM python:3.12-slim

# Prevent bytecode files and send logs directly to stdout/stderr.
# Default to port 5000; PORT can override it at runtime.
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=5000

# Set the working directory inside the container.
WORKDIR /app

# Create a dedicated non-root user and group with fixed IDs.
RUN groupadd --system --gid 10001 appgroup && \
    useradd --system --uid 10001 --gid appgroup \
    --no-create-home --shell /usr/sbin/nologin appuser

# Copy the app and assign it to the unprivileged runtime user.
COPY --chown=10001:10001 app/app.py ./app/app.py

# Run the application as a non-root user.
USER 10001:10001

# Document the application listening port.
EXPOSE 5000

# Start the Python HTTP application.
CMD ["python", "app/app.py"]
