FROM python:3.12-alpine

ENV PYTHONUNBUFFERED=1 \
    PORT=5000

WORKDIR /app

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

COPY app/app.py ./

RUN chown -R appuser:appgroup /app

USER appuser

EXPOSE 5000

CMD ["python", "app.py"]