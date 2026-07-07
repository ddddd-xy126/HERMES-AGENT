#!/usr/bin/env bash
# 将 config.yaml 的 model 改为 providers 声明式 n1n 自定义端点
set -e
CFG="$HOME/.hermes/config.yaml"
python3 - "$CFG" <<'EOF'
import sys, pathlib
p = pathlib.Path(sys.argv[1])
s = p.read_text()
new_block = """model:
  name: claude-opus-4-7
  provider: n1n

providers:
  n1n:
    name: n1n
    base_url: https://api.n1n.ai/v1
    key_env: OPENAI_API_KEY
    default_model: claude-opus-4-7
"""
if "providers:" in s and "n1n" in s:
    print("already patched")
else:
    assert "model: claude-opus-4-7\n" in s, "unexpected config format"
    s = s.replace("model: claude-opus-4-7\n", new_block, 1)
    p.write_text(s)
    print("patched OK")
print("---- head ----")
print(s[:400])
EOF
