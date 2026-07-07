#!/usr/bin/env bash
# 把 BrowserHarness 接入 Hermes：写入 BU_CDP_URL，重启 Gateway
# Usage: bash _wire-browser-harness.sh
set -e

ENV_FILE="$HOME/.hermes/.env"
WIN_HOST=$(ip route | awk '/default/{print $3; exit}')
PORT=9333
URL="http://$WIN_HOST:$PORT"

echo "==> Windows host detected: $WIN_HOST"
echo "==> wiring BU_CDP_URL=$URL into $ENV_FILE"

# 备份 + 删旧的 BH 块 + 追加新块
cp -n "$ENV_FILE" "$ENV_FILE.bak" 2>/dev/null || true
# 删掉之前可能写过的 BU_* 行
sed -i '/^BU_CDP_URL=/d; /^BU_NAME=/d; /^# BrowserHarness/d' "$ENV_FILE"

cat >> "$ENV_FILE" <<EOF

# BrowserHarness — 让 Hermes 调 browser-harness 时连到 Windows 上的 automation Chrome
BU_CDP_URL=$URL
BU_NAME=hermes
EOF

echo "==> .env tail:"
tail -6 "$ENV_FILE"

echo
echo "==> restarting gateway"
bash "$(dirname "$0")/_restart-gateway.sh" | tail -10
