# Windows 原生 Hermes 部署记录（2026-07-07）

> 目标：让 Hermes 拥有**直接操作 Windows 桌面**的能力（点鼠标、打字、截屏、开任意软件）。
> WSL 里的 Hermes 是 Linux 环境，隔着虚拟化边界看不到 Windows 桌面，因此在 Windows 上原生再装一份，两份分工协作。

## 一、最终效果（已实测验证）

| 验证项 | 结果 |
|---|---|
| `hermes -z "你运行在什么系统上"` | ✅ 正确回答 Windows 10（N1n LLM 链路通） |
| `hermes computer-use doctor` | ✅ 全绿：UIAutomation 可达、D3D11 截屏可用、MCP 会话正常 |
| `cua-driver call get_screen_size` | ✅ 读到屏幕 1920×1080 |
| 端到端桌面操作 | ✅ 通过飞书式自然语言指令让 agent 打开记事本并输入文字、截图、创建文件 |

## 二、安装了什么

| 组件 | 版本 | 位置 | 说明 |
|---|---|---|---|
| Hermes Agent | v0.18.0 | `%LOCALAPPDATA%\hermes`（`C:\Users\dengxinyu\AppData\Local\hermes`） | Windows 原生，与 WSL 份完全隔离 |
| uv | 0.11.27 | `%LOCALAPPDATA%\hermes\bin` | Python 包管理器（手动装，见坑①） |
| Python | 3.11.15 | `%APPDATA%\uv\python\` | uv 托管安装 |
| cua-driver | 0.7.0 | `%LOCALAPPDATA%\Programs\Cua\cua-driver\bin` | 桌面控制驱动（Rust 版，Win32 SendInput + UIAutomation 稳定 API），**已注册开机自启**（计划任务 RunLevel=Highest） |
| Playwright Chromium | 149.0.7827.55 | `%LOCALAPPDATA%\ms-playwright` | 浏览器工具（安装脚本自动装） |
| Git / Node.js | 系统已有 2.50.1 / v22.20.0 | — | 安装脚本检测到已装，直接复用 |

## 三、执行过程与踩坑

### 1. 官方一键安装（两次失败后成功）

```powershell
iex (irm https://hermes-agent.nousresearch.com/install.ps1)
```

**坑① uv.exe 被 Windows Defender 误报秒删**：安装脚本装完 uv 后文件立即消失（官方 README 已注明是 ML 引擎对无签名 Rust 二进制的已知误报）。
修复：手动从 GitHub 官方源下载 zip 解压到位——

```powershell
curl.exe -L -o "$env:TEMP\uv.zip" "https://github.com/astral-sh/uv/releases/latest/download/uv-x86_64-pc-windows-msvc.zip"
Expand-Archive "$env:TEMP\uv.zip" -DestinationPath "$env:LOCALAPPDATA\hermes\bin" -Force
```

> 附带经验：GitHub API 会限流（改用 `latest/download` 直链）；PowerShell 5.1 的 `Invoke-WebRequest` 对 GitHub 常报 TLS EOF，下载一律用 `curl.exe -L`。

**坑② `uv python install 3.11` 首次网络瞬断失败**：报 "No interpreter found"，其实是下载中断。手动重跑同一命令即成功。

之后重跑官方脚本一路通过：Playwright、TUI 依赖、PATH、配置模板、60+ 内置 skills 全部就位。

### 2. 安装 cua-driver

```powershell
irm https://raw.githubusercontent.com/trycua/cua/main/libs/cua-driver/scripts/install.ps1 | iex
```

一次成功。自动加入 PATH + 注册开机自启（`cua-driver serve` 每次登录静默启动）。

### 3. 配置迁移（从 WSL 份复制）

- `config.yaml`：model 段改为 n1n 声明式 provider（与 WSL 侧 `set-n1n-provider.sh` 相同写法）：

  ```yaml
  model:
    provider: n1n
    default: claude-fable-5
  providers:
    n1n:
      name: n1n
      base_url: https://api.n1n.ai/v1
      key_env: OPENAI_API_KEY
      default_model: claude-fable-5
  ```

- `.env`：追加 `OPENAI_BASE_URL` / `OPENAI_API_KEY`（N1nKey）。
- **飞书凭据故意不迁**：同一个飞书应用只能被一个 gateway 实例接管，双实例会抢消息/重复回复。飞书仍由 WSL 份负责。

### 4. 启用桌面控制并验证

```powershell
hermes tools enable computer_use --platform cli   # 启用工具集
hermes computer-use doctor                        # 全绿
hermes doctor                                     # 仅剩可选 Key 未配置
```

## 四、两份 Hermes 分工

| | WSL 份（`~/.hermes`） | Windows 份（`%LOCALAPPDATA%\hermes`） |
|---|---|---|
| 飞书机器人 | ✅ 负责 | ❌ 不接（避免抢消息） |
| 写代码 / 跑脚本 | ✅ | ✅ |
| CDP 遥控 automation Chrome | ✅（BrowserHarness） | 可用（自带 Playwright） |
| **操作 Windows 桌面** | ❌ 做不到 | ✅ cua-driver |

## 五、日常使用

```powershell
hermes                 # 交互对话（推荐——实时显示每步工具调用）
hermes -z "指令"       # 一次性执行（过程静默，等最终结果，看似卡住实际在等 LLM 往返）
```

注意事项：

- `launch_app` 设计为**不抢焦点**（后台静默打开），新窗口可能出现在任务栏而不弹到最前。
- 一次 LLM 往返（截屏→分析→操作）约 20~60 秒，桌面任务节奏比对话慢是正常的。
- 若 Defender 再次隔离 `uv.exe`：管理员 PowerShell 执行
  `Add-MpPreference -ExclusionPath "$env:LOCALAPPDATA\hermes\bin"`。
