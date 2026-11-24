FROM python:latest

WORKDIR /app

COPY ./app .

RUN useradd -m taskuser

USER taskuser

ENTRYPOINT ["python"]

CMD ["app.py"]



