#!/usr/bin/env bash
source ~/.hermes/.env
for m in gpt-image-2 gpt-image-1 dall-e-3 dall-e-2 sd3 flux-pro; do
  echo "=== $m ==="
  curl -sS -X POST "$OPENAI_BASE_URL/images/generations" \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -H "Content-Type: application/json" \
    -d "{\"model\":\"$m\",\"prompt\":\"a cute cat\",\"n\":1,\"size\":\"1024x1024\"}" | head -c 300
  echo
done

echo "=== /v1/models 查询可用模型（看图像类） ==="
curl -sS "$OPENAI_BASE_URL/models" -H "Authorization: Bearer $OPENAI_API_KEY" | head -c 4000
echo
