#!/usr/bin/env bash
# 后台启动 Hermes Gateway（飞书等消息平台）
# Usage (in WSL): bash scripts/runtime/start-gateway.sh
set -e

LOG=~/.hermes/logs/gateway.log
PIDFILE=~/.hermes/gateway.pid

if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
  echo "Already running with PID $(cat "$PIDFILE"); restarting..."
  kill "$(cat "$PIDFILE")" || true
  sleep 2
fi

setsid nohup ~/.local/bin/hermes gateway run \
  > "$LOG" 2>&1 < /dev/null &

PID=$!
echo "$PID" > "$PIDFILE"
echo "Started PID=$PID"

sleep 4
echo '--- log tail ---'
tail -30 "$LOG"
echo '---'
if kill -0 "$PID" 2>/dev/null; then
  echo "✓ Gateway running."
else
  echo "✗ Process exited; check log above."
fi
