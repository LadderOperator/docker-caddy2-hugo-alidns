# builder 镜像
FROM caddy:2-builder AS builder

# 设置 Goproxy 以加速
RUN go env -w GOPROXY=https://goproxy.cn,direct

# 编译 Caddy 所需插件
RUN xcaddy build \
    --with github.com/caddy-dns/alidns \
    --with github.com/WingLim/caddy-webhook

# deploy 镜像
FROM caddy:2 AS deploy

# 从 builder 复制编译产物
COPY --from=builder /usr/bin/caddy /usr/bin/caddy

LABEL Maintainer "LadderOperator <tz_ji@qq.com>"

# 设置时区（不重要）
ENV TZ Asia/Shanghai

ARG hugo_version=0.92.0

# 准备基本工具
RUN apk add --no-cache openssh-client git tar curl

# 从 Hugo 仓库下载 Hugo 程序
RUN curl --silent --show-error --fail --location \
  --header "Accept: application/tar+gzip, application/x-gzip, application/octet-stream" -o - \
  "https://github.com/gohugoio/hugo/releases/download/v${hugo_version}/hugo_${hugo_version}_Linux-64bit.tar.gz" \
  | tar --no-same-owner -C /tmp -xz \
  && mv /tmp/hugo /usr/bin/hugo \
  && chmod 0755 /usr/bin/hugo \
  && mkdir -p /blog

# 设置工作目录为 /blog，此为之后克隆 Hugo 博客仓库的位置
WORKDIR /blog

# 复制配置文件，配置文件会将仓库拉入/blog，并且每次更新后执行 Hugo 将其生成静态页面至 /public 下
COPY config.json /etc/caddy/config.json

# 以配置文件执行 Caddy
ENTRYPOINT [ "caddy", "run",  "--config=/etc/caddy/config.json"]
