FROM python:3.12-slim

WORKDIR /app

COPY app/app.py /app/app.py

RUN useradd --create-home --uid 10001 appuser

USER appuser

ENV PORT=5000

EXPOSE 5000

CMD ["python", "-u", "app.py"]
