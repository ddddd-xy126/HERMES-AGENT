#!/usr/bin/env bash
# 把 SKILL.md 替换成「本机部署前言 + 已有 domain-skills 索引 + 上游 SKILL.md」的合并版
# Usage: bash scripts/config-patch/refresh-skill-md.sh
set -e

UPSTREAM="$HOME/Developer/browser-harness/SKILL.md"
SKILL_DIR="$HOME/.hermes/skills/browser-harness"
TARGET="$SKILL_DIR/SKILL.md"

if [ ! -f "$UPSTREAM" ]; then
  echo "ERROR: upstream not found at $UPSTREAM"; exit 1
fi

mkdir -p "$SKILL_DIR"
[ -L "$TARGET" ] && rm "$TARGET"

awk '
  BEGIN { state=0 }
  /^---$/ {
    if (state==0) { state=1; print; next }
    if (state==1) { state=2; print; print ""; print "<!-- INJECT_HERE -->"; next }
  }
  state>=1 { print }
' "$UPSTREAM" > "$TARGET.tmp"

# 动态生成 domain-skills 索引（这样新增 skill 自动出现在提示词里）
SKILL_INDEX="$(mktemp)"
{
  echo "## 已沉淀的 domain-skills（**接到任务先看这里！**）"
  echo
  echo "\`BH_AGENT_WORKSPACE\` 指向 \`~/Developer/browser-harness/agent-workspace\`，其中 \`domain-skills/\` 是 symlink 到 Windows 端工作区，**用户在那里维护**。"
  echo
  echo "**接到任务前必做**：先列 domain-skills 看有没有匹配的 skill："
  echo
  echo '```bash'
  echo "ls ~/Developer/browser-harness/agent-workspace/domain-skills/"
  echo '```'
  echo
  echo "⚠️ \`goto_url()\` 的自动发现是按 hostname 匹配的，**对 IP 地址（比如 51pm 测试环境 \`10.67.8.183\`）不会触发**。任务匹配靠你自己。"
  echo
  echo "### 已知 skill（自动从目录列出）"
  echo
  WS="$HOME/Developer/browser-harness/agent-workspace/domain-skills"
  if [ -d "$WS" ]; then
    for site in $(ls "$WS" | sort); do
      site_dir="$WS/$site"
      [ -d "$site_dir" ] || continue
      mds=$(ls "$site_dir"/*.md 2>/dev/null || true)
      [ -z "$mds" ] && continue
      echo "- **$site** — \`domain-skills/$site/\`"
      for md in $mds; do
        bn=$(basename "$md")
        title=$(head -10 "$md" | grep -m1 -E '^#+ ' | sed 's/^#\+ //' | python3 -c 'import sys; s=sys.stdin.read().rstrip(); print(s[:80])')
        if [ -n "$title" ]; then
          echo "  - \`$bn\` — $title"
        else
          echo "  - \`$bn\`"
        fi
      done
    done
  fi
  echo
  echo "**任务关键词路由**：看到 \"51pm\" / \"本周任务\" / \"组员任务\" / \"完工\" / \"工时\" / \"日报\" / \"验收\" / \"发版\" / \"看板\" / \"测试环境\" → 立刻 cat 对应 md，按里面的步骤执行，不要重新摸索。51PM 测试环境地址、登录方式、Tab 复用规则都在 \`domain-skills/51pm/README.md\`，**任何 51PM 任务先读它，不要猜 URL、不要用 Hermes 原生 browser 工具（会拦内网 IP），一律用 browser-harness**。"
  echo
  echo "如果没匹配的 skill，按上游 SKILL.md 的 \"screenshot first\" 工作流自己探索；探索完务必写回 \`domain-skills/<site>/<task>.md\`。"
  echo
} > "$SKILL_INDEX"

python3 - "$TARGET.tmp" "$SKILL_INDEX" <<'PYEOF'
import sys
target_path, skill_index_path = sys.argv[1], sys.argv[2]
text = open(target_path, encoding='utf-8').read()
skill_index = open(skill_index_path, encoding='utf-8').read()

preamble_top = """## 本机部署说明（爱马仕Lucky on WSL）

**🚨 绝对禁令：永远不要让用户在 PowerShell 里手动跑 chrome 启动命令。这是上一版的兜底方式，已废弃。**

**🚨 绝对禁令 2：永远不要自己启动 WSL 本地的 Playwright/Chromium（`~/.cache/ms-playwright/...`）来干浏览器活。** 那是个无登录态的空白浏览器，打开内网系统只会看到登录页，毫无意义。浏览器活的唯一正确通道是 `browser-harness`（连 Windows 上的 automation Chrome，登录态已持久化）。连不上就跑 ensure-chrome.sh 自愈，自愈失败就停下来告诉用户，**不许换裸浏览器兜底**。

**Chrome 连不上时的唯一正确动作**：你自己跑
```bash
bash /mnt/d/project/hermes-agent/AgentGroups/harmesAgent/scripts/runtime/ensure-chrome.sh
```
这个脚本通过 WSL→Windows interop 自己拉起 Chrome（幂等：在跑就秒退）。等到打印 `✓ Chrome reachable` 后再重试 `browser-harness -c '...'`。

---

**重要：用户已经把这台机器的 Chrome CDP 接入做完了，你不需要再问 Chrome 端口或让用户改启动参数。**

- `BU_CDP_URL` 已写在 `~/.hermes/.env`，指向一台**独立的 automation Chrome**（Windows 上的端口 9333）。
- `BU_NAME=hermes` 已设置，daemon/socket 都走这个命名空间。
- 调用方式：`browser-harness -c '<python>'`。环境变量 daemon 自动读取，**不要在命令里再 export BU_CDP_URL**。
- 运行时 Chrome **是独立 profile，没登录任何账号**。需要登录态时让用户在 automation Chrome 窗口手动登一次，profile 持久化在 `%LOCALAPPDATA%\\\\BrowserHarness\\\\automation-profile`。
- **不要**让用户改日常 Chrome（9222）的启动参数。

"""

preamble_bottom = """**典型工作流：**
```bash
browser-harness -c '
new_tab("https://example.com")
wait_for_load()
capture_screenshot("/tmp/shot.png")
print(page_info())
'
```

## Chrome 自愈（**不要再让用户手动启 Chrome**）

如果 `browser-harness` 报 `BU_CDP_URL ... unreachable` / 任何连接失败 / daemon 起不来，**立刻自己跑**：

```bash
bash /mnt/d/project/hermes-agent/AgentGroups/harmesAgent/scripts/runtime/ensure-chrome.sh
```

这个脚本会通过 WSL→Windows interop 自己拉起 automation Chrome（幂等：已在跑就秒退）。等它打印 `✓ Chrome reachable` 后**再重试**原命令。**不要让用户手动跑 PowerShell**，那是上一版的兜底方式，已废弃。

只有在 ensure-chrome 自己也失败（30s 内 Chrome 没起来）时，才告诉用户：可能他/她在 Windows 上把整个会话锁了 / 杀了 powershell.exe，让用户自己排查。

---

"""

text = text.replace("<!-- INJECT_HERE -->", preamble_top + skill_index + preamble_bottom)
open(target_path, 'w', encoding='utf-8').write(text)
PYEOF

rm -f "$SKILL_INDEX"
mv "$TARGET.tmp" "$TARGET"
echo "==> wrote $TARGET ($(wc -l < "$TARGET") lines)"
echo
echo "==> head 60 lines:"
head -60 "$TARGET"
