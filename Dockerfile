# 编译阶段
FROM ubuntu:22.04 AS builder

# 安装 Flutter 依赖
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# 下载并安装 Flutter
RUN git clone https://github.com/flutter/flutter.git /flutter
ENV PATH="/flutter/bin:${PATH}"

# 预下载依赖
RUN flutter config --enable-web

WORKDIR /app

# 复制项目文件
COPY pubspec.yaml pubspec.lock ./
COPY lib ./lib
COPY web ./web

# 获取 pub 依赖
RUN flutter pub get

# 构建 Web 版本
RUN flutter build web --release

# 运行阶段
FROM python:3.11-slim

WORKDIR /app

# 从编译阶段复制构建输出
COPY --from=builder /app/build/web ./build/web

# 使用 Python HTTP 服务器
EXPOSE 5000

CMD ["python", "-m", "http.server", "5000", "--directory", "build/web"]
