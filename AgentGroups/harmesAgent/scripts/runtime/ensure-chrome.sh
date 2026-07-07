#!/usr/bin/env bash
# 幂等地确保 Windows 上的 automation Chrome 在跑：
#   - 已经在跑 → 立刻退出
#   - 没跑 → 通过 WSL interop 调 powershell.exe 拉起，等到 Chrome 就绪
#
# Hermes 看到 `BU_CDP_URL ... unreachable` 时直接调这个脚本，不要再问用户。
#
# Usage: bash scripts/runtime/ensure-chrome.sh
set -e

WIN_HOST=$(ip route | awk '/default/{print $3; exit}')
PORT=9333
URL="http://$WIN_HOST:$PORT/json/version"

echo "==> probe $URL"
if curl -sS --max-time 3 "$URL" >/dev/null 2>&1; then
  echo "✓ Chrome already up"
  exit 0
fi

echo "==> Chrome unreachable; launching via PowerShell interop"
PS_SCRIPT='d:\project\hermes-agent\AgentGroups\harmesAgent\scripts\runtime\windows\launch-automation-chrome.ps1'
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$PS_SCRIPT" 2>&1 | sed 's/^/    [chrome] /'

echo
echo "==> waiting for Chrome to come up (up to 30s)"
deadline=$(( $(date +%s) + 30 ))
while [ "$(date +%s)" -lt "$deadline" ]; do
  if curl -sS --max-time 2 "$URL" >/dev/null 2>&1; then
    echo "✓ Chrome reachable at $URL"
    exit 0
  fi
  sleep 1
done

echo "✗ Chrome did not become reachable within 30s. Tell user to check Windows side." >&2
exit 1
