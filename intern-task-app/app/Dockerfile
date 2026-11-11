FROM python:3.13-slim
WORKDIR /app
RUN useradd -m myuser
USER myuser
COPY --chown=myuser:myuser ./app /app
EXPOSE 5000
CMD ["python", "app.py"]