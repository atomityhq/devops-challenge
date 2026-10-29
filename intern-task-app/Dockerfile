FROM python:3.12-slim

ENV PORT=5000
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

RUN useradd --system --no-create-home --shell /usr/sbin/nologin appuser

COPY --chown=appuser:appuser app/app.py ./app.py

USER appuser

EXPOSE 5000

CMD ["python", "app.py"]