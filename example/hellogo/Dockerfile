# 使用官方的Go镜像作为基础镜像
FROM golang:1.22 AS build

# 设置工作目录
WORKDIR /app

# 复制应用程序源代码到工作目录
COPY . .

RUN go build -o app ./main.go

# 现在创建一个只有运行时依赖的镜像
FROM alpine:latest

# 将构建好的应用程序复制到新的基础镜像中
COPY --from=build /app/app /app

# 运行应用程序
ENTRYPOINT ["/app"]