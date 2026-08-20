FROM node:24-alpine

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci --omit=dev

COPY api ./api

ENV PORT=8787
EXPOSE 8787

CMD ["npm", "run", "api:start"]
