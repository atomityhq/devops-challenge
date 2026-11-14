
FROM python:3.13-slim


ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

ENV PORT=8080

RUN useradd --system --uid 10001 --no-create-home --shell /usr/sbin/nologin app

WORKDIR /app

COPY app/app.py .

USER 10001

EXPOSE 8080

CMD ["python", "app.py"]
