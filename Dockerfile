FROM caddy:2-builder AS builder

RUN go env -w GOPROXY=https://goproxy.cn,direct

RUN xcaddy build \
    --with github.com/caddy-dns/alidns \
    --with github.com/WingLim/caddy-webhook

FROM caddy:2 AS deploy

COPY --from=builder /usr/bin/caddy /usr/bin/caddy

LABEL Maintainer "LadderOperator <tz_ji@qq.com>"

ENV TZ Asia/Shanghai

ARG hugo_version=0.92.0

RUN apk add --no-cache openssh-client git tar curl

RUN curl --silent --show-error --fail --location \
  --header "Accept: application/tar+gzip, application/x-gzip, application/octet-stream" -o - \
  "https://github.com/gohugoio/hugo/releases/download/v${hugo_version}/hugo_${hugo_version}_Linux-64bit.tar.gz" \
  | tar --no-same-owner -C /tmp -xz \
  && mv /tmp/hugo /usr/bin/hugo \
  && chmod 0755 /usr/bin/hugo \
  && mkdir -p /blog

WORKDIR /blog

COPY config.json /etc/caddy/config.json

ENTRYPOINT [ "caddy", "run",  "--config=/etc/caddy/config.json"]
