#!/usr/bin/env bash
set -e
source ~/.hermes/.env
echo "Base: $OPENAI_BASE_URL"
echo "测试 gpt-image-2 接口..."
curl -sS -X POST "$OPENAI_BASE_URL/images/generations" \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-image-2-medium",
    "prompt": "a cute orange cat sitting on a desk, watercolor style",
    "n": 1,
    "size": "1024x1024"
  }' | head -c 800
echo
