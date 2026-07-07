#!/usr/bin/env bash
# 更新 daily-51pm-tasks-840 cron 的 prompt 为最新版（仓库中的 prompts/cron-daily-tasks.md）
set -e
JOB_ID="${1:-}"
PROMPT_FILE="/mnt/d/webDevFrontProject/AgentGroups/harmesAgent/prompts/cron-daily-tasks.md"
HERMES="${HERMES:-$HOME/.local/bin/hermes}"

if [ -z "$JOB_ID" ]; then
  JOB_ID=$("$HERMES" cron list 2>/dev/null \
    | awk '/^  [0-9a-f]{12} \[/{id=$1} /Name:[[:space:]]+daily-51pm-tasks-840/{print id; exit}')
fi
if [ -z "$JOB_ID" ]; then
  echo "ERROR: cron job 'daily-51pm-tasks-840' not found." >&2
  exit 1
fi
echo "[update-cron] job_id=$JOB_ID"

TMP="$(mktemp)"
tr -d '\r' < "$PROMPT_FILE" > "$TMP"
echo "[update-cron] prompt bytes=$(wc -c < "$TMP")"

PROMPT="$(cat "$TMP")"
"$HERMES" cron edit "$JOB_ID" --prompt "$PROMPT"
rm -f "$TMP"

echo
echo "--- after ---"
"$HERMES" cron list
