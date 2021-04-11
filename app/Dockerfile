FROM node:14.16.1-alpine3.12

WORKDIR /app

COPY package*.json ./

RUN npm install

ENV SERVER_PORT=3000

COPY . /app

EXPOSE 3000

CMD [ "node", "index.js" ]