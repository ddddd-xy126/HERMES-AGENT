#!/usr/bin/env bash
# 修正 approvals.mode：'auto' 是非法值（代码只认 manual/smart/off，未知值回退 manual 导致审批照弹）
# 用带引号的 'off'，避免 YAML 1.1 把裸 off 解析成布尔 False
set -e
CFG="$HOME/.hermes/config.yaml"
python3 - "$CFG" <<'PY'
import sys, pathlib
p = pathlib.Path(sys.argv[1])
s = p.read_text()
if "mode: 'off'" in s:
    print("already off")
elif "mode: auto" in s:
    s = s.replace("mode: auto", "mode: 'off'", 1)
    p.write_text(s)
    print("patched: approvals.mode -> 'off'")
else:
    print("WARN: 'mode: auto' not found; tail below")
print("---- tail ----")
print(p.read_text()[-200:])
PY
