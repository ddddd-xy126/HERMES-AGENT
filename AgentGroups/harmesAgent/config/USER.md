# 全局工作准则（每条消息均会注入，编辑后立即生效）

## A. 51pm 站点
- **默认环境**：正式/生产 `http://51pm.51aes.com:771`。测试环境 `http://10.67.8.183:7777` 仅在用户明确说"测试"时使用。

## B. 浏览器 Tab 复用（强制）
> 这是硬规则。违反会导致用户的 Chrome 出现重复页面。

调用 browser-harness 打开任何 URL 之前，**必须先 `list_tabs(include_chrome=False)` 检查是否已有同站 tab**：
- 命中（URL 包含目标 host 关键字，如 `51pm.51aes.com` 或 `10.67.8.183`）→ `switch_tab(tid)` 复用；若目标路由不同，再用页内导航（`location.href = ...`）或 `cdp("Page.reload")` 确保页面状态正确。
- 未命中 → 才允许 `new_tab(target_url)`。
- **禁止**任何场景下首选 `new_tab`；**禁止**用 `goto_url` 覆盖当前 tab（会污染用户工作）。

只读类查询（看任务状态、看工时等）默认复用现有 tab；写操作类（完工、新建任务）若担心污染再询问用户。

## C. 命令书写规范（避免触发审批）
- 执行 shell 命令必须使用**单条直接命令**；禁止用 `&&`、`;` 拼接成复合命令；禁止 `cd X && Y` 这种前缀。
- 需要工作目录请用绝对路径，或使用 `bash -lc "cd X; Y"` 这种已被白名单覆盖的形态。
- 生成命令前先想：这条命令是否完全匹配 `command_allowlist` 的某条 glob？如不匹配请改写而不是发起需要审批的调用。

## D. 飞书早回执（提升体感）
- 收到任务后，**先在 1 秒内回一句简短确认**（如「收到，正在查 51pm…」），再去执行长操作。
- 长操作期间若超过 30 秒还无结果，**主动给一句中间进度**（如「页面已打开，正在解析任务列表…」）。
- 不要在飞书里发送会让用户困惑的英文 debug 文字，统一中文。

## E. 任务状态变更的稳定性
- 每次改变 51pm 任务状态后，**必须等待表格刷新**再操作下一条（建议 `wait_for_selector` 或显式等待 1.5s）。
- 批量完工时逐条处理；任一条失败立即停下并告知用户哪条出错，不要继续。

## F. 回答风格
- 中文为主；技术细节简洁。
- 不要把内部错误堆栈直接抛给飞书用户；先用一句话告诉用户结论，再问要不要看详情。

## G. Skill 沉淀位置（强制）
> 经验沉淀只允许写到 git 仓库内，禁止落到 Hermes 私有目录。

- **51pm 相关经验**：必须写到 `~/Developer/browser-harness/agent-workspace/domain-skills/51pm/*.md`（即 Windows 的 `BrowserHarness/agent-workspace/domain-skills/51pm/`，软链同步）。已存在 `README.md` / `checkTask_confirmTask.md` / `fill_today_timesheet.md` / `team_schedule_report.md` / `create_daily_task.md`，**优先合并进现有文件**而非新建。
- **其它站点经验**：写到对应的 `domain-skills/<site>/*.md`，没有就先新建目录，但站点名要规范（小写连字符，如 `51pm` `g2` `producthunt`）。
- **绝对禁止**写到 `~/.hermes/skills/`（productivity / creative / etc）下——那是 Hermes 内置 skill 仓库，重装即丢、用户看不到、不进 git。
- **绝对禁止**在 skill 中硬编码个人 PII（姓名、工号、部门具体路径）。这些应作为运行时参数传入，skill 只描述流程模板。
- **绝对禁止**在 skill 中写已废弃的 PowerShell `_launch-automation-chrome.ps1` 路径。Chrome 自愈走 `bash /mnt/d/project/hermes-agent/AgentGroups/harmesAgent/scripts/runtime/ensure-chrome.sh`。
