# FROM node:alpine
FROM --platform=linux/amd64 node:alpine

# Autor/Mantenedor
MAINTAINER Jonathan Baraldi

RUN mkdir -p /src 

# Definir diretório de trabalho
WORKDIR /src
ADD . /src

# Expor porta 80
EXPOSE  8080

# Rodar o app usando nodemon
CMD ["node", "/src/index.js"]