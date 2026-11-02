FROM python:3.12-slim
WORKDIR /app
COPY app/app.py .
RUN useradd --system --no-create-home appuser
USER appuser
ENV PORT=5000
EXPOSE 5000
CMD ["python", "app.py"]