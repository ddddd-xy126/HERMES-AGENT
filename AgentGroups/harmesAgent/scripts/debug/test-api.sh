#!/usr/bin/env bash
# 测试 N1nKey 连通性
set -a; source ~/.hermes/.env; set +a

echo "Endpoint: $OPENAI_BASE_URL"
echo "Model: claude-opus-4-7"
echo "---"

curl -sS -o /tmp/api-test.json -w 'HTTP=%{http_code} TIME=%{time_total}s\n' \
  -X POST "$OPENAI_BASE_URL/chat/completions" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -d '{"model":"claude-opus-4-7","messages":[{"role":"user","content":"reply only the single word: pong"}],"max_tokens":20}'

echo "--- response body ---"
cat /tmp/api-test.json | head -c 800
echo
