#!/usr/bin/env bash
# 把 docs/prompts/config 等非 scripts 文件里的旧路径 webDevFrontProject 批量替换为 project/hermes-agent
# (scripts/ 目录已由 fix-stale-paths.sh 处理过)
set -euo pipefail
cd "$(dirname "$0")/../.."

files=(
  docs/使用教程.md
  docs/产品文档.md
  config/USER.md
  prompts/cron-daily-tasks.md
  prompts/cron-weekly-schedule.md
  prompts/memory-rule.md
  README.md
  launcher/hermes_launcher.py
  skills/cyberpunk-ui/install-hermes-theme.sh
  skills/cyberpunk-ui/SKILL.md
)

for f in "${files[@]}"; do
  [ -f "$f" ] || { echo "skip (missing): $f"; continue; }
  sed -i \
    -e 's|/mnt/d/webDevFrontProject|/mnt/d/project/hermes-agent|g' \
    -e 's|\([Dd]\):\\webDevFrontProject|\1:\\project\\hermes-agent|g' \
    "$f"
  echo "fixed: $f"
done

echo "--- 残留检查 ---"
grep -rn 'webDevFrontProject' docs/ prompts/ config/ README.md launcher/hermes_launcher.py skills/ 2>/dev/null || echo "clean ✓"
