FROM alpine:latest

# 安装必要的依赖
RUN apk add --no-cache curl wget unzip supervisor nodejs npm git

# 创建工作目录
RUN mkdir -p /app /etc/supervisor/conf.d /etc/3x-ui

# 安装3x-ui面板
RUN git clone https://github.com/mhsanaei/3x-ui.git /app/3x-ui && \
    cd /app/3x-ui && \
    npm install && \
    npm run build

# 创建3x-ui配置文件
RUN echo '{"listen": "0.0.0.0", "port": 80, "username": "admin", "password": "admin"}' > /etc/3x-ui/config.json

# 创建supervisor配置文件
RUN echo '[supervisord]\nnodaemon=true\n\n[program:3x-ui]\ncommand=node /app/3x-ui/build/index.js\nautostart=true\nautorestart=true' > /etc/supervisor/conf.d/supervisord.conf

# 暴露端口
EXPOSE 80

# 启动supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
