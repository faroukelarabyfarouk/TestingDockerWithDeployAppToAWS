FROM node:24-alpine AS base

WORKDIR /app

COPY package*.json ./


FROM base AS development

RUN npm ci

COPY . .

EXPOSE 4000

CMD ["npm", "run", "start-dev"]


FROM base AS production

RUN npm ci --omit=dev

COPY . .

EXPOSE 4000

CMD ["npm", "start"]