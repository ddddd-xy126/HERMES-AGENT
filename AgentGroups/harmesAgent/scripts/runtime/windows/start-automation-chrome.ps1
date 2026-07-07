# 启动专用自动化 Chrome 并把 9222 端口暴露给 WSL
# Usage (PowerShell as Admin):  .\_start-automation-chrome.ps1
#
# 设计：
#   - 不动用户日常 Chrome（避免 M144 "Allow remote debugging" 弹窗 / M136 default-profile lockdown）
#   - 用独立 profile 目录 + 9222 端口
#   - 用 netsh portproxy 把 0.0.0.0:9222 → 127.0.0.1:9222，让 WSL 通过 host IP 直接访问
#   - 用法：先在 PowerShell（管理员）跑此脚本；然后 WSL 里直接 `BU_CDP_URL=http://<wsl_host>:9222 browser-harness -c '...'`

param(
  # 默认 9333，避开用户日常 Chrome 常用的 9222
  [int]$Port = 9333,
  [string]$ProfileDir = "$env:LOCALAPPDATA\BrowserHarness\automation-profile",
  [switch]$NoPortproxy
)

$ErrorActionPreference = "Stop"

# 1) 找到 Chrome
$chrome = @(
  "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
  "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
  "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $chrome) {
  Write-Error "Chrome not found. Install Google Chrome or edit this script to point at chrome.exe."
}
Write-Host "==> chrome: $chrome"

# 2) 创建专用 profile 目录
if (-not (Test-Path $ProfileDir)) {
  New-Item -ItemType Directory -Path $ProfileDir -Force | Out-Null
}
Write-Host "==> profile: $ProfileDir"

# 3) 检查端口占用
$inUse = (Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue)
if ($inUse) {
  Write-Host "==> port $Port already in use by PID $($inUse[0].OwningProcess) — assuming an existing automation Chrome; skipping launch"
} else {
  # 4) 启动 Chrome
  #    --remote-debugging-address=0.0.0.0 让 Chrome 接受任何 Host header
  #    （否则 portproxy 转过来的 WSL 请求会被 DNS-rebinding 防护拒绝 → /json/version 404）
  $args = @(
    "--remote-debugging-port=$Port",
    "--remote-debugging-address=0.0.0.0",
    "--remote-allow-origins=*",
    "--user-data-dir=$ProfileDir",
    "--no-first-run",
    "--no-default-browser-check",
    "about:blank"
  )
  Write-Host "==> launching: chrome $($args -join ' ')"
  Start-Process -FilePath $chrome -ArgumentList $args | Out-Null
  Start-Sleep -Seconds 2
}

# 5) 配置 portproxy（让 WSL 通过 host IP 访问）
if (-not $NoPortproxy) {
  Write-Host "==> configure netsh portproxy 0.0.0.0:$Port -> 127.0.0.1:$Port"
  # 删了再加（幂等）
  netsh interface portproxy delete v4tov4 listenport=$Port listenaddress=0.0.0.0 2>$null | Out-Null
  netsh interface portproxy add v4tov4 listenport=$Port listenaddress=0.0.0.0 connectport=$Port connectaddress=127.0.0.1 | Out-Null
  netsh interface portproxy show v4tov4 | Select-String -Pattern $Port

  # 防火墙放行（仅 WSL 子网）—— 默认 WSL 在 172.16/12 私网
  $ruleName = "BrowserHarness-CDP-$Port"
  Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue | Remove-NetFirewallRule -ErrorAction SilentlyContinue
  New-NetFirewallRule -DisplayName $ruleName `
    -Direction Inbound -Action Allow -Protocol TCP -LocalPort $Port `
    -RemoteAddress 172.16.0.0/12 -Profile Any | Out-Null
  Write-Host "==> firewall rule '$ruleName' added (WSL subnet 172.16/12 only)"
}

# 6) 自检
Write-Host "==> probe http://127.0.0.1:$Port/json/version"
try {
  (Invoke-RestMethod -Uri "http://127.0.0.1:$Port/json/version" -TimeoutSec 5) | Format-List
} catch {
  Write-Warning "probe failed: $($_.Exception.Message)"
}

Write-Host ""
Write-Host "Done. In WSL, use:"
Write-Host "  WIN_HOST=`$(ip route | awk '/default/{print `$3; exit}')"
Write-Host "  BU_CDP_URL=http://`$WIN_HOST:$Port browser-harness -c 'print(page_info())'"
