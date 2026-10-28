FROM python:3.13-slim

RUN useradd --system --uid 10001 --no-create-home --shell /usr/sbin/nologin app

WORKDIR /app
COPY app/app.py .

ENV PORT=8080
EXPOSE 8080

USER 10001

STOPSIGNAL SIGINT

CMD ["python", "app.py"]