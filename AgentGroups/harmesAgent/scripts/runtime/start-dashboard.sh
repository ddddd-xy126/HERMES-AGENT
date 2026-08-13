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
# 绑定 127.0.0.1（而非 0.0.0.0）：新版 hermes 禁止无鉴权时绑定非回环地址；
# WSL2 自带 localhost 转发，Windows 侧仍可用 http://localhost:9119 访问
setsid nohup ~/.local/bin/hermes dashboard \
  --host 127.0.0.1 \
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
