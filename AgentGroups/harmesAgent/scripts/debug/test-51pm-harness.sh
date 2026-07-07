#!/usr/bin/env bash
# 验证 browser-harness -> automation Chrome -> 51PM 测试环境链路与登录态
set -e
export PATH="$HOME/.local/bin:$HOME/.hermes/bin:$PATH"
export BU_CDP_URL="http://172.26.176.1:9333"
export BU_NAME="hermes"
browser-harness <<'PY'
new_tab("http://10.67.8.183:7777")
wait_for_load()
import time
time.sleep(4)
capture_screenshot("/tmp/51pm-test.png")
print(page_info())
PY
echo "---- screenshot ----"
ls -la /tmp/51pm-test.png
