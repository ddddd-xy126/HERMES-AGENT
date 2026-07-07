#!/usr/bin/env bash
set -e
pkill -f 'hermes gateway run' || true
sleep 2
rm -f ~/.hermes/gateway.lock ~/.hermes/gateway.pid
bash "$(dirname "$0")/start-gateway.sh"
sleep 3
echo '--- gateway.log tail ---'
tail -30 ~/.hermes/logs/gateway.log
echo '--- ps ---'
ps -ef | grep 'hermes gateway' | grep -v grep || echo "(no process)"
