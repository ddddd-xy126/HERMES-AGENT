# Hermes-Agent 部署工作区（爱马仕Lucky）

在 **Windows + WSL2 Ubuntu** 上部署 [Hermes-Agent](https://github.com/NousResearch/hermes-agent) 的脚本、配置与文档。

## 目录结构

```
harmesAgent/
├── README.md                  当前文件（总入口）
├── config/                    配置模板（env / yaml / USER.md）
├── prompts/                   注入 LLM 的素材（cron prompt、memory rule）
├── scripts/
│   ├── install/               一次性安装：install-hermes / install-cron / wire / allow…
│   ├── runtime/               日常启停：start-/restart-/ensure-chrome/update-cron-daily
│   │   └── windows/           仅 Windows 侧 ps1：launch-automation-chrome 等
│   ├── config-patch/          改 ~/.hermes/config.yaml 的工具：apply-fixes / sync-skills…
│   └── debug/                 出问题时才跑：inspect / list-models / test-api…
├── docs/                      中文文档（产品/教程/WebUI 使用说明）
└── launcher/                  一键启动 exe 源码与构建脚本
```

## 快速启动（最常用）

每天打开电脑后，在 PowerShell 跑：

```powershell
wsl -d Ubuntu -- bash /mnt/d/project/hermes-agent/AgentGroups/harmesAgent/scripts/runtime/start-gateway.sh
wsl -d Ubuntu -- bash /mnt/d/project/hermes-agent/AgentGroups/harmesAgent/scripts/runtime/start-dashboard.sh
```

或者直接双击根目录 `StartHermesLucky.exe`（自动拉起两个并打开 http://localhost:9119）。

## 常见操作

| 场景 | 命令 |
|---|---|
| 改了 `prompts/cron-daily-tasks.md` 想同步进 cron | `wsl -d Ubuntu -- bash /mnt/d/.../scripts/runtime/update-cron-daily.sh` |
| 改了 `~/.hermes/config.yaml` 想生效 | `wsl -d Ubuntu -- bash /mnt/d/.../scripts/runtime/restart-gateway.sh` |
| 飞书机器人没回 | 看 [docs/使用教程.md](docs/使用教程.md) §5 三步自救法 |
| Chrome 连不上 | `wsl -d Ubuntu -- bash /mnt/d/.../scripts/runtime/ensure-chrome.sh` |
| 新增 BrowserHarness skill 想注入 | `wsl -d Ubuntu -- bash /mnt/d/.../scripts/config-patch/sync-skills.sh` |

## 首次部署

参见 [docs/产品文档.md](docs/产品文档.md) 与 [docs/使用教程.md](docs/使用教程.md)。简化版：

1. `wsl --install -d Ubuntu` → 重启 → 设置 Linux 用户。
2. WSL 中：`bash /mnt/d/project/hermes-agent/AgentGroups/harmesAgent/scripts/install/install-hermes.sh`
3. 配置 `~/.hermes/.env`（参考 [config/env.template](config/env.template)）和 `~/.hermes/config.yaml`（参考 [config/config.template.yaml](config/config.template.yaml)）
4. 启动：见上面"快速启动"

## 常见问题

- **WSL 安装失败**：BIOS 启用 CPU 虚拟化（VT-x / SVM）
- **`hermes` 命令找不到**：`source ~/.bashrc`
- **Command Approval Required 弹用户**：`bash scripts/config-patch/apply-fixes.sh`（关闭 Tirith / 设 approvals.mode=auto / 加 allowlist 兜底）
- **API Key 401**：检查 N1nKey 余额与模型名

## 兼容性说明（重组迁移期）

旧文件名（`_start-gateway.sh` 等）已迁到 `scripts/runtime/` 等子目录。在根目录留有少量同名 stub 转发到新位置，便于已部署的 cron / 历史命令继续工作。计划 1~2 周后移除 stub，请尽量改用新路径。

