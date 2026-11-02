FROM python:3.12-slim

ENV PORT=8080

RUN groupadd --system app && \
    useradd --system --gid app --no-create-home app

WORKDIR /app

COPY --chown=app:app app/app.py .

USER app

EXPOSE 8080

CMD ["python", "-u", "app.py"]
