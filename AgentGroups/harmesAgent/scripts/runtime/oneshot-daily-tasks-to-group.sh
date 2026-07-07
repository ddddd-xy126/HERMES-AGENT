#!/usr/bin/env bash
# 临时把 cron-daily-tasks 的 prompt 触发一次，投递到指定飞书群（默认是 wakeup 那个群）。
# 用法：
#   bash scripts/runtime/oneshot-daily-tasks-to-group.sh           # 1 分钟后跑
#   bash scripts/runtime/oneshot-daily-tasks-to-group.sh 30s       # 30 秒后
#   GROUP=oc_xxxx bash scripts/runtime/oneshot-daily-tasks-to-group.sh
set -e
WHEN="${1:-1m}"
GROUP="${GROUP:-oc_16df917222758270fc04f009c6a17c71}"
PROMPT_FILE="/mnt/d/project/hermes-agent/AgentGroups/harmesAgent/prompts/cron-daily-tasks.md"
HERMES="${HERMES:-$HOME/.local/bin/hermes}"

TMP="$(mktemp)"
tr -d '\r' < "$PROMPT_FILE" > "$TMP"
PROMPT="$(cat "$TMP")"
rm -f "$TMP"
echo "[oneshot-daily-to-group] when=$WHEN group=$GROUP bytes=${#PROMPT}"

"$HERMES" cron create \
  --name "daily-tasks-groupshot" \
  --deliver "feishu:$GROUP" \
  --workdir "$HOME/Developer/browser-harness/agent-workspace" \
  "$WHEN" \
  "$PROMPT"

echo
"$HERMES" cron list | tail -8
