# HERMES-AGENT

围绕 [Hermes Agent](https://github.com/NousResearch/hermes-agent) 的个人 AI 助理部署与工具集合，包含部署脚本、浏览器自动化、Web 管理面板等多个子项目。

## 仓库结构

```
hermes-agent/
├── AgentGroups/
│   ├── harmesAgent/       Hermes-Agent 部署工作区（Windows + WSL2 Ubuntu）
│   ├── BrowserHarness/    浏览器自动化 CDP harness（LLM 直连真实浏览器）
│   ├── hermes-web-ui/     Hermes Agent 的 Web 管理面板
│   └── docs/              AI 应用落地相关概念文档
└── aimashi/
    └── hermes-studio/     Hermes Agent 桌面应用 / 本地运行时 / Web 控制台
```

## 子项目简介

### [harmesAgent](AgentGroups/harmesAgent/) — 部署工作区

在 Windows + WSL2 Ubuntu 上部署 Hermes-Agent 的脚本、配置模板与中文文档：

- `scripts/install/` 一次性安装脚本（install-hermes、cron、browser-harness 接线等）
- `scripts/runtime/` 日常启停（start-gateway / restart-gateway / ensure-chrome 等）
- `scripts/config-patch/` 修改 `~/.hermes/config.yaml` 的工具
- `config/` env / yaml / USER.md 配置模板
- `prompts/` 注入 LLM 的 cron prompt 与 memory rule
- `docs/` 产品文档、使用教程、WebUI 使用说明

日常启动：

```powershell
wsl -d Ubuntu -- bash /mnt/d/project/hermes-agent/AgentGroups/harmesAgent/scripts/runtime/start-gateway.sh
wsl -d Ubuntu -- bash /mnt/d/project/hermes-agent/AgentGroups/harmesAgent/scripts/runtime/start-dashboard.sh
```

详见 [harmesAgent/README.md](AgentGroups/harmesAgent/README.md)。

### [BrowserHarness](AgentGroups/BrowserHarness/) — 浏览器自动化

轻量可编辑的 CDP harness，让 LLM 通过一条 WebSocket 直连真实 Chrome。Agent 在执行中自行补齐缺失的 helper，harness 随每次运行自我改进。

- `agent-workspace/domain-skills/` 领域技能（如 51pm 工时填报自动化）
- `interaction-skills/` 交互技能文档（iframe、上传、下载、对话框等）

详见 [BrowserHarness/README.md](AgentGroups/BrowserHarness/README.md)。

### [hermes-web-ui](AgentGroups/hermes-web-ui/) — Web 管理面板

Hermes Agent 的全功能 Web 管理面板：管理 AI 聊天会话、监控用量与成本、配置平台渠道、管理定时任务、浏览技能。

```bash
npm install -g hermes-web-ui && hermes-web-ui start
```

详见 [hermes-web-ui/README_zh.md](AgentGroups/hermes-web-ui/README_zh.md)。

### [hermes-studio](aimashi/hermes-studio/) — 桌面应用与控制台

面向 Hermes Agent 的桌面应用、本地运行时和 Web 控制台：聊天、模型与 Profile 管理、平台渠道接入、任务自动化、文件查看、Coding Agent 一体化界面。

详见 [hermes-studio/README_zh.md](aimashi/hermes-studio/README_zh.md)。

## 快速开始

1. 安装 WSL2：`wsl --install -d Ubuntu`，重启后设置 Linux 用户
2. 在 WSL 中安装 Hermes：`bash AgentGroups/harmesAgent/scripts/install/install-hermes.sh`
3. 配置 `~/.hermes/.env` 与 `~/.hermes/config.yaml`（参考 [config 模板](AgentGroups/harmesAgent/config/)）
4. 启动 gateway 与 dashboard（见上方"日常启动"）

首次部署完整流程见 [使用教程](AgentGroups/harmesAgent/docs/使用教程.md) 与 [产品文档](AgentGroups/harmesAgent/docs/产品文档.md)。

## License

各子项目遵循其目录下的 LICENSE 文件。
