#!/usr/bin/env bash
# 安装 Cyberpunk 主题 + Skin 到 Hermes Dashboard
# 同时处理两套体系：
#   1) Dashboard 主题   → ~/.hermes/dashboard-themes/cyberpunk.yaml  （React 外壳）
#   2) CLI/TUI Skin     → ~/.hermes/skins/cyberpunk.yaml  （终端内 hermes 输出）
# 并把 config.yaml 里 display.skin 改成 cyberpunk，重启 dashboard。
#
# 用法（WSL Ubuntu）：
#   bash install-hermes-theme.sh
# 或 Windows PowerShell:
#   wsl -d Ubuntu bash /mnt/d/.../skills/cyberpunk-ui/install-hermes-theme.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
THEME_SRC="$SCRIPT_DIR/theme/hermes-cyberpunk.yaml"
SKIN_SRC="$SCRIPT_DIR/skin/hermes-cyberpunk-skin.yaml"

THEME_DIR="$HOME/.hermes/dashboard-themes"
SKIN_DIR="$HOME/.hermes/skins"
THEME_DST="$THEME_DIR/cyberpunk.yaml"
SKIN_DST="$SKIN_DIR/cyberpunk.yaml"
CONFIG="$HOME/.hermes/config.yaml"
DASHBOARD_PORT="${DASHBOARD_PORT:-9119}"

# ---- 1) 主题（外壳） ----
if [ ! -f "$THEME_SRC" ]; then
  echo "✗ 找不到主题源文件: $THEME_SRC"; exit 1
fi
mkdir -p "$THEME_DIR"
cp "$THEME_SRC" "$THEME_DST"
echo "✓ Dashboard 主题: $THEME_DST"

# ---- 2) Skin（终端内输出） ----
if [ ! -f "$SKIN_SRC" ]; then
  echo "✗ 找不到 skin 源文件: $SKIN_SRC"; exit 1
fi
mkdir -p "$SKIN_DIR"
cp "$SKIN_SRC" "$SKIN_DST"
echo "✓ CLI/TUI Skin: $SKIN_DST"

# ---- 3) 切换 config.yaml 里 display.skin ----
if [ -f "$CONFIG" ]; then
  if grep -qE '^\s*skin:\s*' "$CONFIG"; then
    sed -i -E 's|^(\s*skin:\s*).*|\1cyberpunk|' "$CONFIG"
    echo "✓ config.yaml: display.skin → cyberpunk"
  else
    echo "⚠  config.yaml 未找到 'skin:' 行，请手动在 display: 下加 'skin: cyberpunk'"
  fi
else
  echo "⚠  未找到 $CONFIG，跳过 config 修改"
fi

# ---- 4) 重启 Dashboard（skin 在 hermes --tui 启动时才加载，必须重启） ----
DASH_SH="/mnt/d/webDevFrontProject/AgentGroups/harmesAgent/scripts/runtime/start-dashboard.sh"
if [ -f "$DASH_SH" ]; then
  echo "↻ 重启 Dashboard…"
  bash "$DASH_SH" || true
else
  # 备选：只触发外壳重扫（不会重加 TUI skin）
  curl -fsS "http://127.0.0.1:${DASHBOARD_PORT}/api/dashboard/plugins/rescan" >/dev/null 2>&1 \
    && echo "✓ 已触发主题重扫（skin 需重启 Dashboard 才生效）" \
    || echo "ℹ Dashboard 未运行；启动后主题+skin 会一同生效。"
fi

echo ""
echo "下一步："
echo "  1. 打开 http://localhost:${DASHBOARD_PORT}"
echo "  2. 顽强刷新（Ctrl+Shift+R）"
echo "  3. 顶部主题切换器选 'Cyberpunk'（外壳）"
echo "  4. 进入「对话」页 → 应看到青色 HERMES figlet 与黑底（skin 生效）"
