# Backend multi-stage build
FROM node:20-alpine AS builder
WORKDIR /app
COPY backend/package*.json ./
RUN npm ci
COPY backend/. .
RUN npm run build || true

FROM node:20-alpine
WORKDIR /app
COPY --from=builder /app .
RUN npm ci --only=production
USER node
EXPOSE 5000
CMD ["node", "src/server.js"]
