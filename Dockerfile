# 使用轻量级的 Nginx 镜像作为基础镜像
FROM nginx:stable-alpine

# 将 Flutter Web 构建产物复制到 Nginx 默认的 HTML 目录
COPY build/web /usr/share/nginx/html

# 复制自定义 Nginx 配置（可选，解决 SPA 路由问题）
# COPY nginx.conf /etc/nginx/conf.d/default.conf

# 暴露 80 端口
EXPOSE 80

# 启动 Nginx
CMD ["nginx", "-g", "daemon off;"]
