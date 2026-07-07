#!/usr/bin/env bash
# 把 N1nKey 配置写入 ~/.hermes/.env 和 ~/.hermes/config.yaml
# 在 WSL 中运行：bash /mnt/d/webDevFrontProject/AgentGroups/harmesAgent/scripts/config-patch/apply-config.sh <API_KEY>
# 注意：API Key 通过参数 $1 传入，避免硬编码
set -e

KEY="${1:?Usage: bash _apply-config.sh <API_KEY>}"
HOME_DIR="${HOME:-/home/$(whoami)}"
ENV_FILE="$HOME_DIR/.hermes/.env"
CFG_FILE="$HOME_DIR/.hermes/config.yaml"

# 备份
cp -n "$ENV_FILE" "$ENV_FILE.bak" 2>/dev/null || true
cp -n "$CFG_FILE" "$CFG_FILE.bak" 2>/dev/null || true

# 1) 在 .env 末尾追加 N1nKey 配置（去掉旧的同名行）
sed -i '/^OPENAI_BASE_URL=/d;     /^OPENAI_API_KEY=/d' "$ENV_FILE"
cat >> "$ENV_FILE" <<EOF

# ===== N1nKey 中转（OpenAI 兼容） =====
OPENAI_BASE_URL=https://api.n1n.ai/v1
OPENAI_API_KEY=$KEY
EOF

# 2) 更新 config.yaml 的 default model / provider / base_url
python3 - "$CFG_FILE" <<'PYEOF'
import re, sys
p = sys.argv[1]
src = open(p, encoding='utf-8').read()
src = re.sub(r'(\n\s*default:\s*)"[^"]*"', r'\1"claude-opus-4-7"', src, count=1)
src = re.sub(r'(\n\s*provider:\s*)"[^"]*"', r'\1"custom"',          src, count=1)
src = re.sub(r'(\n\s*base_url:\s*)"[^"]*"', r'\1"https://api.n1n.ai/v1"', src, count=1)
open(p, 'w', encoding='utf-8').write(src)
print("config.yaml patched")
PYEOF

echo "✓ Done. 验证："
echo "  - $ENV_FILE  (末尾已追加 N1nKey 块)"
echo "  - $CFG_FILE  (model.default / provider / base_url 已更新)"
