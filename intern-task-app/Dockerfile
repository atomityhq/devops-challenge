FROM python:3.13-slim-bookworm

WORKDIR /app

ENV PORT=5000

RUN useradd --create-home --uid 10001 appuser

COPY app/app.py ./app.py

USER 10001

EXPOSE 5000

CMD ["python", "app.py"]