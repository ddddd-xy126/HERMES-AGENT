#!/usr/bin/env bash
# 安装 hermes-web-ui（EKKOLearnAI/hermes-web-ui）到 Hermes 内嵌的 node 环境。
#
# 设计：
#   - 复用 ~/.hermes/node/bin/{node,npm}，不污染系统
#   - npm 全局前缀指向 ~/.hermes/node（默认就是），bin 也在该目录下
#   - 安装后直接调 ~/.hermes/node/bin/hermes-web-ui
set -e

NODE_DIR="$HOME/.hermes/node"
NODE_BIN="$NODE_DIR/bin"
# 注意：web-ui daemon 会派生 `hermes gateway run`，必须把 ~/.local/bin 放进 PATH
export PATH="$NODE_BIN:$HOME/.local/bin:$HOME/bin:$PATH"

if [ ! -x "$NODE_BIN/node" ]; then
  echo "missing: $NODE_BIN/node — 请先用 hermes setup 或重装 Hermes"
  exit 1
fi

echo "[install-web-ui] node $(node -v)  npm $(npm -v)"
echo "[install-web-ui] npm prefix: $(npm config get prefix)"

# 安装（已装则升级到最新）
echo "[install-web-ui] installing hermes-web-ui ..."
npm install -g hermes-web-ui

echo
echo "[install-web-ui] binary at: $(command -v hermes-web-ui || echo NOT-FOUND)"
hermes-web-ui -v || true

# 启动（后台 daemon 模式），固定 8648 端口
echo
echo "[install-web-ui] starting on :8648 ..."
hermes-web-ui start --port 8648 || true

echo
echo "[install-web-ui] status:"
hermes-web-ui status || true

echo
echo "=== done. 浏览器打开 http://localhost:8648 ==="
