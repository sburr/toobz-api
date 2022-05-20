FROM node:18-alpine3.14

RUN apk add dumb-init && \
	mkdir /usr/local/lib/node_modules/toobz-api

WORKDIR /usr/local/lib/node_modules/toobz-api

COPY dist dist
COPY package.json package.json
COPY sslcert /etc/ssl/toobz

RUN npm install --omit=dev

CMD [ "dumb-init", "node", "dist/index.js" ]