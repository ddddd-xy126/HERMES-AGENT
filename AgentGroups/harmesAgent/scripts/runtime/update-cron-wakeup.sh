#!/usr/bin/env bash
# 注册或更新 cron：morning-wakeup-750
#   - 每天 07:50 给指定群发一条御姐音色叫醒语音
#   - prompt 来源 prompts/cron-morning-wakeup.md
set -e
JOB_ID="${1:-}"
JOB_NAME="morning-wakeup-750"
SCHEDULE="50 7 * * *"
DELIVER="feishu:oc_4acae77f85894216ca236042a336df17"
WORKDIR="$HOME/Developer/browser-harness/agent-workspace"
PROMPT_FILE="/mnt/d/webDevFrontProject/AgentGroups/harmesAgent/prompts/cron-morning-wakeup.md"
HERMES="${HERMES:-$HOME/.local/bin/hermes}"

if [ -z "$JOB_ID" ]; then
  JOB_ID=$("$HERMES" cron list 2>/dev/null \
    | awk -v name="$JOB_NAME" '/^  [0-9a-f]{12} \[/{id=$1} $1=="Name:" && $2==name {print id; exit}')
fi

TMP="$(mktemp)"
tr -d '\r' < "$PROMPT_FILE" > "$TMP"
PROMPT="$(cat "$TMP")"
rm -f "$TMP"
echo "[update-cron-wakeup] prompt bytes=$(printf '%s' "$PROMPT" | wc -c)"

if [ -z "$JOB_ID" ]; then
  echo "[update-cron-wakeup] creating new job '$JOB_NAME' @ '$SCHEDULE'"
  "$HERMES" cron create \
    --name "$JOB_NAME" \
    --deliver "$DELIVER" \
    --workdir "$WORKDIR" \
    "$SCHEDULE" \
    "$PROMPT"
else
  echo "[update-cron-wakeup] updating existing job_id=$JOB_ID"
  "$HERMES" cron edit "$JOB_ID" --prompt "$PROMPT"
fi

echo
echo "--- after ---"
"$HERMES" cron list
