#!/usr/bin/env python3
"""Patch ~/.hermes/config.yaml -> 飞书侧静默 tool_progress + interim_assistant_messages。

幂等：只更新这两条 key，不动其它。
"""
from pathlib import Path
import yaml, sys, time, shutil

CFG = Path.home() / ".hermes" / "config.yaml"
if not CFG.exists():
    sys.exit("[clean-feishu-output] config.yaml not found")

shutil.copy(CFG, CFG.with_suffix(f".yaml.bak.cleanfeishu.{int(time.time())}"))

data = yaml.safe_load(CFG.read_text(encoding="utf-8")) or {}
display = data.setdefault("display", {})
platforms = display.setdefault("platforms", {})
if not isinstance(platforms, dict):
    platforms = {}
    display["platforms"] = platforms
feishu = platforms.setdefault("feishu", {})
feishu["tool_progress"] = "off"
feishu["interim_assistant_messages"] = False
feishu["streaming"] = False

CFG.write_text(yaml.safe_dump(data, allow_unicode=True, sort_keys=False), encoding="utf-8")
print("[clean-feishu-output] applied:")
print(f"  display.platforms.feishu.tool_progress = off")
print(f"  display.platforms.feishu.interim_assistant_messages = false")
print(f"  display.platforms.feishu.streaming = false")
