#!/usr/bin/env bash
# 让 Hermes 原生 browser 工具直连 Windows automation Chrome(CDP)
set -e
ENV_FILE="$HOME/.hermes/.env"
WIN_HOST=$(ip route | awk '/default/{print $3; exit}')

echo "==> windows host = $WIN_HOST"
curl -sS --max-time 4 "http://$WIN_HOST:9333/json/version" | head -2 || { echo "!! CDP 不可达"; exit 1; }

sed -i '/^BROWSER_CDP_URL=/d' "$ENV_FILE"
echo "BROWSER_CDP_URL=http://$WIN_HOST:9333" >> "$ENV_FILE"
grep -E '^(BROWSER_CDP_URL|BU_CDP_URL)' "$ENV_FILE"

# 修复 skill 信任警告:软链接换成实体拷贝
SKILL_DIR="$HOME/.hermes/skills/browser-harness"
if [ -L "$SKILL_DIR/SKILL.md" ]; then
  rm "$SKILL_DIR/SKILL.md"
  cp "$HOME/Developer/browser-harness/SKILL.md" "$SKILL_DIR/SKILL.md"
  echo "==> SKILL.md 已改为实体文件"
fi
echo OK
