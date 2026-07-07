#!/usr/bin/env bash
# 在 WSL 中把 BrowserHarness 装成 uv tool，并把 SKILL.md 软链到 ~/.hermes/skills/
# Usage: bash _install-browser-harness.sh
#
# 注意：BrowserHarness 必须 clone 到 WSL 原生文件系统（~/Developer/）。
# 直接从 /mnt/d 安装会因 setuptools 写 egg-info 时权限问题失败。
set -e

REPO="$HOME/Developer/browser-harness"
SKILL_DIR="$HOME/.hermes/skills/browser-harness"

echo "==> 1/3 ensure repo at $REPO (clone if missing, else git pull)"
mkdir -p "$HOME/Developer"
if [ -d "$REPO/.git" ]; then
  git -C "$REPO" pull --ff-only || true
else
  git clone https://github.com/browser-use/browser-harness "$REPO"
fi

echo "==> 1b/3 install browser-harness (editable) from $REPO"
~/.local/bin/uv tool install -e "$REPO" 2>&1 | tail -10

echo "==> 2/3 verify command on PATH"
export PATH="$HOME/.local/bin:$PATH"
~/.local/bin/uv tool update-shell 2>&1 | tail -3 || true
which browser-harness
~/.local/bin/browser-harness --version 2>&1 | head -3 || true

echo "==> 3/3 link SKILL.md into ~/.hermes/skills/browser-harness/"
mkdir -p "$SKILL_DIR"
ln -sf "$REPO/SKILL.md" "$SKILL_DIR/SKILL.md"
ls -la "$SKILL_DIR"

echo
echo "==> probe Windows host Chrome CDP"
WIN_HOST=$(ip route | awk '/default/{print $3; exit}')
echo "windows host = $WIN_HOST"
for port in 9222 9333; do
  echo "-- probing $WIN_HOST:$port --"
  curl -sS --max-time 3 "http://$WIN_HOST:$port/json/version" 2>&1 | head -5 || echo "(no response)"
done
