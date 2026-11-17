FROM python:3.13-slim
WORKDIR /app
COPY app/app.py ./app.py
RUN useradd --create-home appuser
USER appuser
EXPOSE 5000
CMD ["python", "app.py"]