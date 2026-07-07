#!/usr/bin/env bash
# 后台启动 Hermes Dashboard
# Usage: bash scripts/runtime/start-dashboard.sh
set -e

LOG=~/.hermes/logs/dashboard.log
PIDFILE=~/.hermes/dashboard.pid

# 如已运行则先停
if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
  echo "Already running with PID $(cat "$PIDFILE"); restarting..."
  kill "$(cat "$PIDFILE")" || true
  sleep 1
fi

# setsid + nohup 让进程脱离 WSL 终端会话
setsid nohup ~/.local/bin/hermes dashboard \
  --host 0.0.0.0 \
  --insecure \
  --no-open \
  --tui \
  --port 9119 \
  > "$LOG" 2>&1 < /dev/null &

PID=$!
echo "$PID" > "$PIDFILE"
echo "Started PID=$PID"

sleep 3
echo '--- listening sockets ---'
ss -lntp 2>/dev/null | grep 9119 || netstat -lntp 2>/dev/null | grep 9119 || echo '(not listening yet)'
echo '--- log tail ---'
tail -30 "$LOG"
