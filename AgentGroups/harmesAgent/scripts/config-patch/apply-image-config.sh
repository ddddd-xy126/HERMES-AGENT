#!/usr/bin/env bash
# 在 ~/.hermes/config.yaml 末尾添加 image_gen 配置（如果还没有）
set -e
CFG=~/.hermes/config.yaml

if grep -q '^image_gen:' "$CFG"; then
  echo "image_gen 段已存在，跳过追加"
else
  cat >> "$CFG" <<'EOF'

# ===== 图像生成（通过 N1nKey 走 OpenAI 兼容接口） =====
image_gen:
  provider: "openai"           # 使用 plugins/image_gen/openai 插件
  openai:
    model: "gpt-image-2-medium"  # 可选: gpt-image-2-low / -medium / -high
EOF
  echo "✓ 已追加 image_gen 配置"
fi

echo '--- current image_gen section ---'
sed -n '/^image_gen:/,/^[a-z]/p' "$CFG" | head -10
