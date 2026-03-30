#!/bin/sh
set -eu

: "${SS_SERVER:?SS_SERVER is required}"
: "${SS_PORT:?SS_PORT is required}"
: "${SS_METHOD:?SS_METHOD is required}"
: "${SS_PASSWORD:?SS_PASSWORD is required}"
: "${PROXY_USER:?PROXY_USER is required}"
: "${PROXY_PASS:?PROXY_PASS is required}"

SS_LOCAL_ADDR="${SS_LOCAL_ADDR:-127.0.0.1}"
SS_LOCAL_PORT="${SS_LOCAL_PORT:-1080}"
HTTP_PROXY_PORT="${HTTP_PROXY_PORT:-2080}"
SOCKS_PROXY_PORT="${SOCKS_PROXY_PORT:-2081}"

echo "[1/4] Generating 3proxy config..."
sed \
  -e "s|\${PROXY_USER}|${PROXY_USER}|g" \
  -e "s|\${PROXY_PASS}|${PROXY_PASS}|g" \
  -e "s|\${SS_LOCAL_ADDR}|${SS_LOCAL_ADDR}|g" \
  -e "s|\${SS_LOCAL_PORT}|${SS_LOCAL_PORT}|g" \
  -e "s|\${HTTP_PROXY_PORT}|${HTTP_PROXY_PORT}|g" \
  -e "s|\${SOCKS_PROXY_PORT}|${SOCKS_PROXY_PORT}|g" \
  /etc/3proxy/3proxy.cfg.template > /etc/3proxy/3proxy.cfg

echo "[2/4] Generating shadowsocks config..."
sed \
  -e "s|\${SS_SERVER}|${SS_SERVER}|g" \
  -e "s|\${SS_PORT}|${SS_PORT}|g" \
  -e "s|\${SS_PASSWORD}|${SS_PASSWORD}|g" \
  -e "s|\${SS_METHOD}|${SS_METHOD}|g" \
  -e "s|\${SS_LOCAL_PORT}|${SS_LOCAL_PORT}|g" \
  /etc/ss-config.json.template > /etc/ss-config.json

echo "[3/4] Starting sslocal..."
/opt/ss/sslocal -c /etc/ss-config.json &

SSLOCAL_PID=$!

sleep 2

if ! kill -0 "${SSLOCAL_PID}" 2>/dev/null; then
  echo "sslocal failed to start"
  exit 1
fi

echo "[4/4] Starting 3proxy..."
exec 3proxy /etc/3proxy/3proxy.cfg
