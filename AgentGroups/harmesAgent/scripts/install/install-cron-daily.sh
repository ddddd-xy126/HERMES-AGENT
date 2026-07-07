#!/bin/bash
set -e
PROMPT_FILE="${1:-/tmp/cron-prompt.md}"
PROMPT=$(cat "$PROMPT_FILE")
echo "[mkcron] prompt length=${#PROMPT}"
HERMES="${HERMES:-$HOME/.local/bin/hermes}"
"$HERMES" cron create "40 8 * * *" "$PROMPT" \
  --name daily-51pm-tasks-840 \
  --deliver "feishu:oc_4acae77f85894216ca236042a336df17" \
  --workdir /home/huazhonghao/Developer/browser-harness/agent-workspace
echo "[mkcron] exit=$?"
"$HERMES" cron list
