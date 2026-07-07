# Cyberpunk UI Skill

> 一套可复用的「赛博朋克 / HUD / 黑客终端」前端视觉规范与 CSS 组件包。
> 当用户要求做这种风格的界面时，agent 应直接套用本目录下的 tokens / components / animations，
> 而不是凭感觉手写。

---

## 何时使用本 skill

触发关键词（用户描述里出现以下任一即可调用）：

- 赛博朋克 / Cyberpunk / 2077
- 科幻 / Sci-Fi / 未来感
- HUD / 飞船控制台 / 战术界面
- 黑客 / 终端 / Matrix / 数据流
- 霓虹 / Neon / 故障 / Glitch

不适用的场景（请走默认设计系统而不是本 skill）：

- 企业后台、政府/医疗/金融等需要稳重感的产品
- 儿童/教育/电商等需要明亮色彩的产品
- 阅读密集型内容站（长时间凝视霓虹色伤眼）

---

## 核心设计原则（必须遵守）

1. **深色打底，霓虹点缀**
   - 背景使用 `--bg-base` / `--bg-panel`（接近纯黑或深蓝紫）
   - 霓虹色只用于：强调文字、边框、关键交互元素
   - **禁止** 把整块大面积区域填充成霓虹色

2. **最多 2 个霓虹强调色**
   - 主色：青色 `--neon-cyan` （信息/默认）
   - 辅色：品红 `--neon-magenta` （警告/危险/CTA）
   - 第三色（绿/紫/黄）只能极小面积使用，例如徽章、状态点

3. **切角而非圆角**
   - 卡片/按钮使用 `clip-path` 切角，不要 `border-radius`
   - 切角尺寸固定使用 `--clip-sm` / `--clip-md` / `--clip-lg`

4. **等宽字体打底**
   - 数字、ID、状态、按钮文字一律使用 `--font-mono`
   - 标题可选用 `--font-display`（Orbitron 类几何无衬线）
   - 中文正文使用 `--font-cn`

5. **节制使用动效**
   - 扫描线、辉光脉冲、闪烁光标可全局开启
   - Glitch 效果只用于少量关键元素（页面标题、报错状态），**不要** 整页都在抖动

6. **可访问性底线**
   - 文字与背景对比度 ≥ 4.5:1（即使是霓虹色也要保证）
   - 提供 `prefers-reduced-motion` 兜底，关闭动画
   - 不要把"重要信息只用颜色表达"，要配图标或文字

---

## 文件结构与用法

```
cyberpunk-ui/
├── SKILL.md              ← 你正在读的这个
├── tokens.css            ← 全局变量（颜色/字体/切角/阴影）
├── animations.css        ← 关键帧动画（脉冲/扫描/闪烁/数据流）
├── components/
│   ├── buttons.css       ← .cyber-btn / .cyber-btn--danger
│   ├── panels.css        ← .cyber-panel / .cyber-panel__header
│   ├── glitch.css        ← .glitch（需要 data-text 属性）
│   └── scanlines.css     ← .scanlines（挂在 body 上）
├── theme/
│   └── hermes-cyberpunk.yaml  ← Hermes Dashboard 主题文件（直接套到 9119 端口的 WebUI）
├── install-hermes-theme.sh    ← 一键把上面的 yaml 装到 ~/.hermes/dashboard-themes/
└── examples/
    └── dashboard.html         ← 独立示例（与 hermes 无关，直接浏览器打开预览风格）
```

**最小引入顺序**（顺序很重要，tokens 必须最先）：

```html
<link rel="stylesheet" href="cyberpunk-ui/tokens.css">
<link rel="stylesheet" href="cyberpunk-ui/animations.css">
<link rel="stylesheet" href="cyberpunk-ui/components/buttons.css">
<link rel="stylesheet" href="cyberpunk-ui/components/panels.css">
<link rel="stylesheet" href="cyberpunk-ui/components/glitch.css">
<link rel="stylesheet" href="cyberpunk-ui/components/scanlines.css">
```

---

## 决策速查表

| 用户意图 | 推荐做法 |
|---|---|
| 做一个登录/启动页 | `panels.css` 居中卡片 + `glitch.css` 标题 + `buttons.css` 主按钮 |
| 改造管理后台/Dashboard | 整体套 `tokens.css` + `panels.css`，保留布局，只换皮 |
| 想要"非常炸"的首屏 | 加 `scanlines` + 标题 glitch + 网格背景（见 examples/dashboard.html）|
| 用户说"太刺眼" | 调小 `--glow-strength`，把品红替换为更柔和的紫色 `#bd00ff` |
| 用户说"不够酷" | 增加扫描线对比度、给关键按钮加 `animation: neon-pulse` |

---

## 应用到 Hermes Dashboard（端口 9119）

Hermes Dashboard 自带主题系统：把 YAML 丢进 `~/.hermes/dashboard-themes/`，
在主题切换器里就能选。**不需要改 hermes 源码**。

```bash
# WSL Ubuntu 内执行
bash /mnt/d/webDevFrontProject/AgentGroups/harmesAgent/skills/cyberpunk-ui/install-hermes-theme.sh
```

或 Windows PowerShell 一行：

```powershell
wsl -d Ubuntu bash /mnt/d/webDevFrontProject/AgentGroups/harmesAgent/skills/cyberpunk-ui/install-hermes-theme.sh
```

脚本会：
1. 复制 `theme/hermes-cyberpunk.yaml` → `~/.hermes/dashboard-themes/cyberpunk.yaml`
2. 调 `GET /api/dashboard/plugins/rescan` 让 Dashboard 重新扫描
3. 打开 http://localhost:9119 → 顶部主题切换器选 **Cyberpunk**

> 微调建议：所有视觉参数（颜色、辉光强度、扫描线密度、字体）都集中在
> `theme/hermes-cyberpunk.yaml` 里，改完重新跑安装脚本即可。

---

## 反模式（不要这么做）

- ❌ 满屏发光（所有元素都加 box-shadow 霓虹光）→ 视觉噪声爆炸
- ❌ 大面积纯霓虹色背景 → 伤眼且廉价感
- ❌ 圆角 + 渐变彩虹 → 那是 Y2K / Vaporwave，不是 Cyberpunk
- ❌ 用 Comic Sans / 思源宋体做正文 → 风格冲突
- ❌ 给所有文字加 glitch → 用户没法看清内容

## 扩展指南

新增组件时，请：

1. 在 `components/` 下新建一个 css 文件，文件名 = 组件名
2. 所有颜色/尺寸引用 `tokens.css` 里的变量，不要硬编码
3. 类名前缀统一用 `.cyber-`
4. 在本文件「文件结构」段落补一行说明
