# 1.Base image
# using lightweight python 3.12 image.
FROM python:3.12-slim


# 2. Python Environment
# Preventing python from creating unnecessary .pyc files
ENV PYTHONDONTWRITEBYTECODE=1
# Send python output directly to container logs.
ENV PYTHONUNBUFFERED=1
# Configure the application's listening port
ENV PORT=5000


# 3. Working directory
# set the working directory inside the container.
WORKDIR /app


# 4. Create a Non-Root User
# Create a dedicated system group and user
RUN groupadd --system app \
    && useradd --system --gid app --no-create-home app


# 5. Copy Application
# Copy the python application into the container
# Give ownership to the non-root user
COPY --chown=app:app app/app.py ./app.py


# 6. Security: Run without Root Privileges
# Run the application using our dedicated user
USER app


# 7. Application Port Documentation
# Documets that the application listens on port 5000
EXPOSE 5000

# 8. Start the Application
# Use exec form so Python runs as the container's
# main process and receives termination signals directly.
CMD ["python", "sapp.py"]