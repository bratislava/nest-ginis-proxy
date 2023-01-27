# build
FROM node:16.10.0 AS build

RUN apt-get update && apt-get install git

WORKDIR /root/app
COPY package.json yarn.lock ./

RUN yarn install --production

COPY . ./

RUN yarn build

# development
FROM node:16.10.0 AS dev

RUN apt-get update && apt-get install -y git \
    curl \
    vim

WORKDIR /home/node/app
COPY package.json yarn.lock ./

RUN yarn
COPY . ./

CMD yarn start:debug


# production
FROM node:16.10.0-alpine AS prod

USER node

RUN mkdir -p /home/node/app && chown -R node:node /home/node/app
WORKDIR /home/node/app

COPY --chown=node:node --from=build /root/app/package.json ./
COPY --chown=node:node --from=build /root/app/yarn.lock ./
COPY --chown=node:node --from=build /root/app/node_modules ./node_modules

COPY --chown=node:node --from=build /root/app/dist ./dist
COPY --chown=node:node nest-cli.json ./nest-cli.json

ENTRYPOINT yarn start:prod


