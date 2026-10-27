FROM python:3.12-slim
ENV PORT=8080
RUN useradd --uid 10001 --no-create-home --shell /usr/sbin/nologin app
WORKDIR /app
COPY app/app.py .
EXPOSE 8080
USER 10001
STOPSIGNAL SIGINT
CMD ["python", "app.py"]