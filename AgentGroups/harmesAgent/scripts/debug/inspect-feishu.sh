#!/usr/bin/env bash
grep -n FEISHU ~/.hermes/hermes-agent/gateway/platforms/feishu.py | head -60
echo '---'
grep -nE 'FEISHU_(APP|TOKEN|SECRET|TRANSPORT|WEBHOOK|VERIFICATION|ENCRYPT|BOT|ALLOWED|DOMAIN)' ~/.hermes/hermes-agent/gateway/config.py 2>/dev/null | head -30
echo '---env example?---'
ls ~/.hermes/hermes-agent/.env* 2>/dev/null
grep -nE 'FEISHU_|LARK_' ~/.hermes/hermes-agent/agent/.env.example 2>/dev/null | head -40
grep -rnE '^FEISHU_' ~/.hermes/hermes-agent 2>/dev/null | grep -v '__pycache__' | head -30
