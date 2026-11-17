FROM python:3.12-slim

WORKDIR /app

RUN useradd --system --uid 10001 appuser

COPY app/app.py .

USER 10001

ENV PORT=5000

EXPOSE 5000

CMD ["python", "-u", "app.py"]
