#!/usr/bin/env bash
# 给 Hermes 配置：
#   1) 允许访问内网 IP（不再把 10.x / 172.16-31 / 192.168 标 MEDIUM）
#   2) 关闭 Tirith 安全扫描器（它会因 raw IP / 可疑 URL 弹审批卡片）
#   3) browser-harness 命令加入 allowlist，不再每次问审批
#
# ⚠️ 关 Tirith 后，LLM 返回的命令不再被扫描。仅适合个人机器。
#   生产环境建议保留 tirith_enabled: true，单独给 browser-harness 加 URL allowlist。
# Usage: bash scripts/install/allow-browser-harness.sh
set -e

CFG="$HOME/.hermes/config.yaml"
cp -n "$CFG" "$CFG.bak.$(date +%s)" 2>/dev/null || true

python3 - "$CFG" <<'PYEOF'
import re, sys
p = sys.argv[1]
src = open(p, encoding='utf-8').read()

# 1) allow_private_urls: false -> true（全部出现处）
n = len(re.findall(r'\n\s*allow_private_urls:\s*false', src))
src = re.sub(r'(\n\s*allow_private_urls:\s*)false', r'\1true', src)
print(f"✓ allow_private_urls: false -> true ({n} occurrence(s))")

# 2) tirith_enabled: true -> false
n = len(re.findall(r'\n\s*tirith_enabled:\s*true', src))
src = re.sub(r'(\n\s*tirith_enabled:\s*)true', r'\1false', src)
print(f"✓ tirith_enabled: true -> false ({n} occurrence(s))")

# 3) command_allowlist: [] -> 加入 browser-harness
new_list = '''command_allowlist:
  - "browser-harness *"
  - "browser-harness"
'''
src2 = re.sub(r'\ncommand_allowlist:\s*\[\s*\]\n', '\n' + new_list, src, count=1)
if src2 == src:
    print("WARN: command_allowlist: [] 未找到（可能已被改过）")
else:
    print("✓ command_allowlist += browser-harness")
src = src2

open(p, 'w', encoding='utf-8').write(src)
PYEOF

echo "==> 验证："
grep -nE 'allow_private_urls|tirith_enabled|command_allowlist' "$CFG" | head -10

echo
echo "==> restart gateway"
bash "$(dirname "$0")/../runtime/restart-gateway.sh" | tail -8
