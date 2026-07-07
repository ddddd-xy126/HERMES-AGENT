#!/usr/bin/env bash
# Hermes-Agent 一键安装脚本（在 WSL2 / Ubuntu 内执行）
# 用法：bash install-hermes.sh

set -e

echo "==> 1/4 更新系统并安装基础依赖"
sudo apt update
sudo apt install -y curl git build-essential ripgrep ffmpeg

echo "==> 2/4 运行 Hermes-Agent 官方安装脚本"
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash

echo "==> 3/4 加载 shell 环境"
# 兼容 bash / zsh
if [ -f "$HOME/.bashrc" ]; then
  # shellcheck disable=SC1091
  source "$HOME/.bashrc" || true
fi

echo "==> 4/4 安装完成。下一步："
echo "    1) 运行 'hermes setup' 进行交互式配置（选择 OpenRouter 作为 provider）"
echo "    2) 准备好你的 OpenRouter API Key（https://openrouter.ai/keys）"
echo "    3) 配置完成后运行 'hermes doctor' 验证，再运行 'hermes' 启动对话"
