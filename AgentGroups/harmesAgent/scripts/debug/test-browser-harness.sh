#!/usr/bin/env bash
# 测试 BrowserHarness 是否能从 WSL 连到 Windows 上的 Chrome CDP
set -e
PORT="${1:-9333}"
WIN_HOST=$(ip route | awk '/default/{print $3; exit}')
echo "WIN_HOST=$WIN_HOST  PORT=$PORT"
echo "==> probe http://$WIN_HOST:$PORT/json/version"
curl -sS --max-time 5 "http://$WIN_HOST:$PORT/json/version" | head -30
echo
echo "==> running browser-harness with BU_CDP_URL"
export BU_CDP_URL="http://$WIN_HOST:$PORT"
export BU_NAME="hermes"
~/.local/bin/browser-harness -c 'print(page_info())' 2>&1 | head -40
