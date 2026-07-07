#!/usr/bin/env bash
# 完成 BrowserHarness 接线:链接 SKILL、探测并写入 BU_CDP_URL
set -e
export PATH="$HOME/.hermes/bin:$HOME/.local/bin:$PATH"

echo "==> 1/4 link SKILL.md"
mkdir -p "$HOME/.hermes/skills/browser-harness"
ln -sf "$HOME/Developer/browser-harness/SKILL.md" "$HOME/.hermes/skills/browser-harness/SKILL.md"

echo "==> 2/4 probe Windows Chrome CDP"
WIN_HOST=$(ip route | awk '/default/{print $3; exit}')
echo "windows host = $WIN_HOST"
if ! curl -sS --max-time 3 "http://$WIN_HOST:9333/json/version" | head -3; then
  echo "!! CDP 探测失败:WSL 连不到 $WIN_HOST:9333"
  echo "   可能是 Windows 防火墙拦了,或 WSL 是 NAT 模式需要 portproxy"
  exit 1
fi

echo "==> 3/4 write BU_CDP_URL into ~/.hermes/.env"
ENV_FILE="$HOME/.hermes/.env"
sed -i '/^BU_CDP_URL=/d; /^BU_NAME=/d; /^# BrowserHarness/d' "$ENV_FILE"
{
  echo ""
  echo "# BrowserHarness — Hermes 经 CDP 控制 Windows 上的 automation Chrome"
  echo "BU_CDP_URL=http://$WIN_HOST:9333"
  echo "BU_NAME=hermes"
} >> "$ENV_FILE"
grep -E '^BU_' "$ENV_FILE"

echo "==> 4/4 verify browser-harness command"
which browser-harness
echo "OK"
