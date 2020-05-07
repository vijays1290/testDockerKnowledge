FROM node:10.15.3

RUN apt-get update && apt-get install -y wget --no-install-recommends \
    && wget --no-check-certificate -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    && apt-get update \
    && apt-get install -y google-chrome-stable \
      --no-install-recommends 

WORKDIR /app

COPY /package.json /package-lock.json ./.npmrc ./

RUN npm ci

COPY . .

RUN npm run lint

RUN npm run test

RUN npm run build

FROM nginx:alpine
COPY --from=0 /app/dist/testDockerKnowledge /usr/share/nginx/html

COPY --from=0 /app/test-results /test-results
EXPOSE 80