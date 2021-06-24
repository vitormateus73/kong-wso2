FROM python:3-buster

EXPOSE 8005

WORKDIR /app

COPY jwks.json ./

CMD python -m http.server 8005
