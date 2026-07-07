#!/usr/bin/env python3
"""把仓库 persona/user-rule-*.md 同步追加到 ~/.hermes/memories/USER.md（幂等）。

每个文件第一行 ## X. 是哨兵；若 USER.md 已含该哨兵则跳过。
"""
from pathlib import Path
import sys

SRC_DIR = Path("/mnt/d/project/hermes-agent/AgentGroups/harmesAgent/persona")
DST = Path.home() / ".hermes" / "memories" / "USER.md"

if not DST.exists():
    sys.exit(f"missing: {DST}")

src_text = DST.read_text(encoding="utf-8")
written = []

for src in sorted(SRC_DIR.glob("user-rule-*.md")):
    body = src.read_text(encoding="utf-8")
    # 取第一个 ## 开头的行作为哨兵
    sentinel = next((ln for ln in body.splitlines() if ln.startswith("## ")), None)
    if not sentinel:
        continue
    if sentinel in src_text:
        print(f"  - {src.name}: already present ({sentinel})")
        continue
    # 用 § 分隔符
    if not src_text.rstrip().endswith("§"):
        src_text = src_text.rstrip() + "\n§\n"
    # body 自身可能以 § 开头，避免重复
    src_text += body.lstrip("§\n") + "\n"
    written.append(src.name)

DST.write_text(src_text, encoding="utf-8")
print(f"appended: {written}; total {DST.stat().st_size} bytes")
