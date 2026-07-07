#!/usr/bin/env bash
# 一次性修正仓库搬家(d:\project\hermes-agent -> d:\project\hermes-agent)后脚本里的旧路径残留
set -e
ROOT="/mnt/d/project/hermes-agent/AgentGroups/harmesAgent"
cd "$ROOT"

files=$(grep -rl 'webDevFrontProject' scripts/ 2>/dev/null || true)
if [ -z "$files" ]; then
  echo "no stale paths found"
  exit 0
fi

for f in $files; do
  # WSL 侧路径：/mnt/d/project/hermes-agent/... -> /mnt/d/project/hermes-agent/...
  sed -i 's|/mnt/d/project/hermes-agent|/mnt/d/project/hermes-agent|g' "$f"
  # Windows 侧路径：d:\project\hermes-agent\... -> d:\project\hermes-agent\...
  sed -i 's|d:\\webDevFrontProject|d:\\project\\hermes-agent|g' "$f"
  echo "fixed: $f"
done

echo "---- verify ----"
grep -rn 'webDevFrontProject' scripts/ || echo "clean ✓"
