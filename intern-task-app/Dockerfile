FROM python:3.13-slim-bookworm

WORKDIR /app
ENV PORT=5001
COPY app/app.py ./app.py

USER 10001:10001
EXPOSE 5001
CMD ["python", "app.py"]