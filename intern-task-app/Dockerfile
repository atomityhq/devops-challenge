FROM python:3.15.1-alpine
WORKDIR /app
RUN adduser -D appuser
COPY app/app.py .
USER appuser
ENV port=5000
EXPOSE 5000
CMD ["python", "app.py"]