FROM node:20-alpine AS build
WORKDIR /src
COPY package*.json tsconfig.json ./
RUN npm install
COPY src ./src
RUN npm run build

FROM node:20-alpine
RUN apk upgrade --no-cache && rm -rf /usr/local/lib/node_modules/npm
RUN addgroup -g 10001 app && adduser -D -u 10001 -G app app
WORKDIR /app
COPY --from=build /src/node_modules ./node_modules
COPY --from=build /src/dist ./dist
COPY package*.json ./
USER app
EXPOSE 3000
CMD ["node", "dist/server.js"]
