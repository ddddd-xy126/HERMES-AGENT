#!/usr/bin/env bash
# 一键同步 BrowserHarness skills 给 Hermes：
#   1) 重新生成 ~/.hermes/skills/browser-harness/SKILL.md（合并部署前言 + 上游 + 自动索引）
#   2) 重启 Hermes Gateway，让 LLM 提示词加载新内容
#
# 何时跑：
#   - 在 d:\project\hermes-agent\AgentGroups\BrowserHarness\agent-workspace\domain-skills\ 下
#     新增/重命名了一个 site 目录或 .md 文件
#   - 改了一个 .md 的 H1 标题
#   - 升级了 BrowserHarness 上游 SKILL.md
#
# 何时**不用**跑（symlink 实时生效）：
#   - 修改某个已存在 .md 的正文内容（Hermes 不会重新读 SKILL.md，但 agent 会在
#     执行任务时 cat 那个 md，所以新内容立刻可见）
#
# Usage: bash scripts/config-patch/sync-skills.sh
set -e

DIR="$(dirname "$0")"
bash "$DIR/refresh-skill-md.sh"
echo
echo "==> restarting Hermes gateway"
pkill -9 -f 'hermes gateway run' 2>/dev/null || true
sleep 2
rm -f ~/.hermes/gateway.pid
bash "$DIR/../runtime/start-gateway.sh" | tail -6
