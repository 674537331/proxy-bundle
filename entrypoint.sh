#!/bin/sh
set -eu

# 必填环境变量检查
: "${SS_SERVER:?SS_SERVER is required}"
: "${SS_PORT:?SS_PORT is required}"
: "${SS_METHOD:?SS_METHOD is required}"
: "${SS_PASSWORD:?SS_PASSWORD is required}"
: "${PROXY_USER:?PROXY_USER is required}"
: "${PROXY_PASS:?PROXY_PASS is required}"

# 可选环境变量默认值
SS_LOCAL_ADDR="${SS_LOCAL_ADDR:-127.0.0.1}"
SS_LOCAL_PORT="${SS_LOCAL_PORT:-1080}"
HTTP_PROXY_PORT="${HTTP_PROXY_PORT:-2080}"
SOCKS_PROXY_PORT="${SOCKS_PROXY_PORT:-2081}"

echo "[1/3] Generating 3proxy config..."
sed \
  -e "s|\${PROXY_USER}|${PROXY_USER}|g" \
  -e "s|\${PROXY_PASS}|${PROXY_PASS}|g" \
  -e "s|\${SS_LOCAL_ADDR}|${SS_LOCAL_ADDR}|g" \
  -e "s|\${SS_LOCAL_PORT}|${SS_LOCAL_PORT}|g" \
  -e "s|\${HTTP_PROXY_PORT}|${HTTP_PROXY_PORT}|g" \
  -e "s|\${SOCKS_PROXY_PORT}|${SOCKS_PROXY_PORT}|g" \
  /etc/3proxy/3proxy.cfg.template > /etc/3proxy/3proxy.cfg

echo "[2/3] Starting sslocal..."
/opt/ss/sslocal \
  -s "${SS_SERVER}" \
  -p "${SS_PORT}" \
  -m "${SS_METHOD}" \
  -k "${SS_PASSWORD}" \
  -b 0.0.0.0 \
  -l "${SS_LOCAL_PORT}" &

SSLOCAL_PID=$!

sleep 2

if ! kill -0 "${SSLOCAL_PID}" 2>/dev/null; then
  echo "sslocal failed to start"
  exit 1
fi

echo "[3/3] Starting 3proxy..."
exec 3proxy /etc/3proxy/3proxy.cfg
