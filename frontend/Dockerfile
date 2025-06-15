FROM node:22.15.0-alpine AS development

RUN apk add --no-cache libc6-compat
WORKDIR /app

COPY package.json package-lock.json* ./
RUN npm ci

COPY . .

EXPOSE 3000

CMD ["npm", "run", "dev"]