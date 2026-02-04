# 多阶段构建

# 1️⃣ 前端构建
FROM node:18-alpine AS frontend-builder
WORKDIR /app/frontend

COPY frontend/package*.json ./
RUN npm install
COPY frontend/ .
RUN npm run build

# 2️⃣ 后端 Go 构建
FROM golang:1.20-alpine AS backend-builder
WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download
COPY . .
COPY --from=frontend-builder /app/frontend/dist ./frontend/dist

RUN CGO_ENABLED=0 GOOS=linux go build -o gui-singbox .

# 3️⃣ 生产镜像
FROM alpine:3.18
WORKDIR /app

COPY --from=backend-builder /app/gui-singbox .
COPY --from=backend-builder /app/frontend/dist ./frontend/dist

RUN mkdir -p /app/data && chmod 777 /app/data

EXPOSE 8080

CMD ["./gui-singbox"]
