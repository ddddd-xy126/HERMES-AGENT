#!/usr/bin/env bash
# 一次性修复爱马仕 Lucky 的三类问题：
#   1) Command Approval 弹窗 → approvals.mode: auto
#   2) 流式输出未开 → streaming.enabled: true
#   3) command_allowlist 增加兜底 "*"（个人机器自用）
#
# 用法（在 WSL Ubuntu 内执行）:
#   bash /mnt/d/project/hermes-agent/AgentGroups/harmesAgent/scripts/config-patch/apply-fixes.sh
set -euo pipefail

CFG="$HOME/.hermes/config.yaml"
TS=$(date +%Y%m%d-%H%M%S)
cp "$CFG" "$CFG.bak.$TS"
echo "[backup] $CFG.bak.$TS"

# 1) approvals.mode: manual -> auto
#    匹配 "approvals:" 段下紧跟着的 "  mode: ..." 行
python3 - "$CFG" <<'PY'
import sys, re, pathlib
p = pathlib.Path(sys.argv[1])
text = p.read_text()

# (a) approvals.mode -> 'off'（注意：合法值只有 manual/smart/off，'auto' 是非法值会回退 manual；off 必须带引号防 YAML 布尔化）
text = re.sub(
    r"(\napprovals:\n(?:[ \t]+[^\n]*\n)*?[ \t]+mode:[ \t]*)([^\n]+)",
    r"\1'off'",
    text,
    count=1,
)

# (b) streaming.enabled -> true（顶层 streaming: 段，非 display.streaming）
text = re.sub(
    r"(\nstreaming:\n(?:[ \t]+[^\n]*\n)*?[ \t]+enabled:[ \t]*)([^\n]+)",
    r"\1true",
    text,
    count=1,
)

# (c) command_allowlist 加兜底 "*"（如尚未存在）
m = re.search(r"\ncommand_allowlist:\n((?:- [^\n]+\n)+)", text)
if m:
    block = m.group(1)
    if "- '*'" not in block and "- \"*\"" not in block and "- *" not in block:
        new_block = block + "- '*'\n"
        text = text[: m.start(1)] + new_block + text[m.end(1):]

p.write_text(text)
print("[patch] applied: approvals.mode=auto, streaming.enabled=true, allowlist += '*'")
PY

echo "--- diff (旧 vs 新) ---"
diff "$CFG.bak.$TS" "$CFG" || true
echo "--- done ---"
