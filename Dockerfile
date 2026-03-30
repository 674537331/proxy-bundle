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
    gcc \
    make \
    libc6-dev \
    git \
    && rm -rf /var/lib/apt/lists/*

# 编译安装 3proxy
RUN git clone https://github.com/3proxy/3proxy.git /tmp/3proxy \
    && make -C /tmp/3proxy -f Makefile.Linux \
    && cp /tmp/3proxy/bin/3proxy /usr/local/bin/3proxy \
    && chmod +x /usr/local/bin/3proxy \
    && mkdir -p /etc/3proxy \
    && rm -rf /tmp/3proxy

# 安装 shadowsocks-rust
RUN wget -O /tmp/shadowsocks.tar.xz https://github.com/shadowsocks/shadowsocks-rust/releases/download/v1.23.5/shadowsocks-v1.23.5.x86_64-unknown-linux-gnu.tar.xz \
    && mkdir -p /opt/ss \
    && tar -xJf /tmp/shadowsocks.tar.xz -C /opt/ss \
    && chmod +x /opt/ss/sslocal \
    && rm -f /tmp/shadowsocks.tar.xz

COPY 3proxy.cfg.template /etc/3proxy/3proxy.cfg.template
COPY ss-config.json.template /etc/ss-config.json.template
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

EXPOSE 2080 2081

CMD ["/entrypoint.sh"]
