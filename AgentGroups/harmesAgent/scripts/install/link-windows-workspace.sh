#!/usr/bin/env bash
# 让 WSL 的 browser-harness 用 Windows 端 BrowserHarness 仓库的 domain-skills，
# 这样你在 Windows 编辑器里维护的 51pm 等 skill 立即对 Hermes 生效。
#
# 设计：
#   - WSL 端 workspace 仍在 ~/Developer/browser-harness/agent-workspace（避免 /mnt/d 写权限坑）
#   - 把 domain-skills 整个目录替换为指向 Windows workspace 的 symlink
#   - 设置 BH_AGENT_WORKSPACE 显式（默认值就是这个，但写明更稳）
#
# Usage: bash _link-windows-workspace.sh
set -e

WSL_WS="$HOME/Developer/browser-harness/agent-workspace"
WIN_WS="/mnt/d/webDevFrontProject/AgentGroups/BrowserHarness/agent-workspace"

if [ ! -d "$WIN_WS" ]; then
  echo "ERROR: Windows workspace not found at $WIN_WS"; exit 1
fi

echo "==> WSL workspace: $WSL_WS"
echo "==> Windows workspace: $WIN_WS"
echo

# 备份 WSL 原有 domain-skills（如果存在且不是 symlink）
if [ -d "$WSL_WS/domain-skills" ] && [ ! -L "$WSL_WS/domain-skills" ]; then
  BACKUP="$WSL_WS/domain-skills.bak.$(date +%s)"
  echo "==> backing up existing domain-skills -> $BACKUP"
  mv "$WSL_WS/domain-skills" "$BACKUP"
fi

# symlink domain-skills（让 Windows 编辑器/git 仍是单一事实源）
echo "==> symlink domain-skills"
ln -sfn "$WIN_WS/domain-skills" "$WSL_WS/domain-skills"
ls -la "$WSL_WS/domain-skills"

# 同时 symlink agent_helpers.py（如果 Windows 端比 WSL 端新的话）
if [ -f "$WIN_WS/agent_helpers.py" ]; then
  if [ ! -L "$WSL_WS/agent_helpers.py" ]; then
    if [ -f "$WSL_WS/agent_helpers.py" ]; then
      BACKUP="$WSL_WS/agent_helpers.py.bak.$(date +%s)"
      mv "$WSL_WS/agent_helpers.py" "$BACKUP"
      echo "==> backed up old agent_helpers.py -> $BACKUP"
    fi
    ln -sfn "$WIN_WS/agent_helpers.py" "$WSL_WS/agent_helpers.py"
    echo "==> symlinked agent_helpers.py"
  fi
fi

# 验证 51pm skill 可见
echo
echo "==> 51pm skills accessible from WSL workspace:"
ls "$WSL_WS/domain-skills/51pm/"

# 确保 BH_AGENT_WORKSPACE 写在 .env（默认值就是它，但写明更稳；也方便以后切换）
ENV_FILE="$HOME/.hermes/.env"
sed -i '/^BH_AGENT_WORKSPACE=/d' "$ENV_FILE"
echo "BH_AGENT_WORKSPACE=$WSL_WS" >> "$ENV_FILE"
echo
echo "==> .env 末尾：" && tail -5 "$ENV_FILE"

echo
echo "==> restart gateway to pick up env"
pkill -9 -f 'hermes gateway run' 2>/dev/null || true
sleep 2
rm -f ~/.hermes/gateway.pid
bash "$(dirname "$0")/_start-gateway.sh" | tail -6
