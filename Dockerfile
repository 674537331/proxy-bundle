FROM debian:12-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    wget \
    xz-utils \
    procps \
    net-tools \
    sed \
    3proxy \
    && rm -rf /var/lib/apt/lists/*

# 安装 shadowsocks-rust
RUN wget -O /tmp/shadowsocks.tar.xz https://github.com/shadowsocks/shadowsocks-rust/releases/download/v1.23.5/shadowsocks-v1.23.5.x86_64-unknown-linux-gnu.tar.xz \
    && mkdir -p /opt/ss \
    && tar -xJf /tmp/shadowsocks.tar.xz -C /opt/ss \
    && chmod +x /opt/ss/sslocal \
    && rm -f /tmp/shadowsocks.tar.xz

COPY 3proxy.cfg.template /etc/3proxy/3proxy.cfg.template
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

EXPOSE 2080 2081

CMD ["/entrypoint.sh"]
