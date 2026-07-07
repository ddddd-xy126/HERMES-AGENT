#!/usr/bin/env bash
set -e
PROMPT_FILE="/mnt/d/project/hermes-agent/AgentGroups/harmesAgent/prompts/oneshot-cosmic-brief.md"
RUN_AT="${1:-2026-05-09T20:00:00}"
TARGET_DELIVER="${DELIVER:-feishu:oc_4acae77f85894216ca236042a336df17}"
HERMES="${HERMES:-$HOME/.local/bin/hermes}"

TMP="$(mktemp)"
tr -d '\r' < "$PROMPT_FILE" > "$TMP"
PROMPT="$(cat "$TMP")"
rm -f "$TMP"
echo "[oneshot] run_at=$RUN_AT bytes=${#PROMPT}"

"$HERMES" cron create \
  --name "cosmic-brief-2000" \
  --deliver "$TARGET_DELIVER" \
  --workdir "$HOME/Developer/browser-harness/agent-workspace" \
  "$RUN_AT" \
  "$PROMPT"
echo
"$HERMES" cron list
