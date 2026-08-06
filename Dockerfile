FROM node:20-alpine AS dependencies

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci


FROM node:20-alpine AS build

WORKDIR /app

COPY --from=dependencies /app/node_modules ./node_modules
COPY package.json package-lock.json remix.config.js remix.env.d.ts tsconfig.json ./
COPY app ./app

RUN npm run build


FROM node:20-alpine AS production-dependencies

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci --omit=dev && npm cache clean --force


FROM node:20-alpine AS runtime

ENV NODE_ENV=production \
    HOST=0.0.0.0 \
    PORT=3000

WORKDIR /app

COPY --from=production-dependencies --chown=node:node /app/node_modules ./node_modules
COPY --from=build --chown=node:node /app/build ./build
COPY --chown=node:node package.json ./package.json

USER node

EXPOSE 3000

CMD ["npm", "run", "start"]
