#!/usr/bin/env bash
# 注册或更新 cron：weekly-schedule-900
#   - 每天 09:00 推 Web 端开发组「今天→本周最后工作日」排期简报
#   - prompt 来源 prompts/cron-weekly-schedule.md
# Usage:
#   bash scripts/runtime/update-cron-weekly-schedule.sh           # 自动找/创建
#   bash scripts/runtime/update-cron-weekly-schedule.sh <job_id>  # 强制更新指定 id
set -e
JOB_ID="${1:-}"
JOB_NAME="weekly-schedule-900"
SCHEDULE="0 9 * * *"
DELIVER="feishu:oc_4acae77f85894216ca236042a336df17"
WORKDIR="$HOME/Developer/browser-harness/agent-workspace"
PROMPT_FILE="/mnt/d/webDevFrontProject/AgentGroups/harmesAgent/prompts/cron-weekly-schedule.md"
HERMES="${HERMES:-$HOME/.local/bin/hermes}"

if [ -z "$JOB_ID" ]; then
  JOB_ID=$("$HERMES" cron list 2>/dev/null \
    | awk -v name="$JOB_NAME" '/^  [0-9a-f]{12} \[/{id=$1} $1=="Name:" && $2==name {print id; exit}')
fi

TMP="$(mktemp)"
tr -d '\r' < "$PROMPT_FILE" > "$TMP"
PROMPT="$(cat "$TMP")"
rm -f "$TMP"
echo "[update-cron-weekly] prompt bytes=$(printf '%s' "$PROMPT" | wc -c)"

if [ -z "$JOB_ID" ]; then
  echo "[update-cron-weekly] creating new job '$JOB_NAME' @ '$SCHEDULE'"
  "$HERMES" cron create \
    --name "$JOB_NAME" \
    --deliver "$DELIVER" \
    --workdir "$WORKDIR" \
    "$SCHEDULE" \
    "$PROMPT"
else
  echo "[update-cron-weekly] updating existing job_id=$JOB_ID"
  "$HERMES" cron edit "$JOB_ID" --prompt "$PROMPT"
fi

echo
echo "--- after ---"
"$HERMES" cron list
