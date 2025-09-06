FROM node:22.15.0-alpine AS development

RUN apk add --no-cache libc6-compat
WORKDIR /app

COPY package.json package-lock.json* ./
RUN npm config set registry https://registry.npmjs.org/ && \
    npm config set fetch-timeout 300000 && \
    npm config set fetch-retry-maxtimeout 120000 && \
    npm config set fetch-retry-mintimeout 10000 && \
    npm install --frozen-lockfile

COPY . .

EXPOSE 3000

CMD ["npm", "run", "dev"]