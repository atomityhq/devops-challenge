FROM python:3.12-slim
WORKDIR /appn
ENV PORT=8080
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
COPY app/app.py ./app.py
RUN useradd --no-create-home --uid 10001 appuser
USER 10001:10001
EXPOSE 8080
CMD ["python", "app.py"]
