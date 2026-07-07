
# 浏览器自动化（BrowserHarness）规则 — 强制执行

调 `browser-harness` 报 "BU_CDP_URL ... unreachable" 或任何连接失败时：**立刻自己跑**
`bash /mnt/d/webDevFrontProject/AgentGroups/harmesAgent/scripts/runtime/ensure-chrome.sh`，等 `✓ Chrome reachable` 后再重试原命令。

**绝对禁止**让用户手动跑 PowerShell / `_launch-automation-chrome.ps1` — 那是已废弃的兜底。
只有 `_ensure-chrome.sh` 也失败（30s 超时）时，才告诉用户排查。

任务来自 51pm（"本周任务"/"组员"/"完工"/"工时"/"日报"等关键词）时，对应 skill 在
`~/Developer/browser-harness/agent-workspace/domain-skills/51pm/` 下，先 cat 对应 md 再行动。
