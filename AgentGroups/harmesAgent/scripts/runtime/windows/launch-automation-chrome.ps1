# 仅启动专用 automation Chrome（不需要管理员）
# Usage:  powershell -ExecutionPolicy Bypass -File .\_launch-automation-chrome.ps1
param(
  [int]$Port = 9333,
  [string]$ProfileDir = "$env:LOCALAPPDATA\BrowserHarness\automation-profile"
)

$ErrorActionPreference = "Stop"

$chrome = @(
  "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
  "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
  "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $chrome) { Write-Error "Chrome not found." }

if (-not (Test-Path $ProfileDir)) {
  New-Item -ItemType Directory -Path $ProfileDir -Force | Out-Null
}

# 检查端口上有没有真正的 Chrome（OwningProcess 是 chrome.exe 才算）
$listen = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
if ($listen) {
  $proc = Get-Process -Id $listen.OwningProcess -ErrorAction SilentlyContinue
  if ($proc -and $proc.ProcessName -eq 'chrome') {
    Write-Host "==> Chrome already on $Port (PID $($proc.Id))"
    exit 0
  }
  Write-Host "==> port $Port held by $($proc.ProcessName) (PID $($listen.OwningProcess)) — that's the portproxy listener; Chrome launch will bind 127.0.0.1:$Port behind it"
}

$args = @(
  "--remote-debugging-port=$Port",
  "--remote-debugging-address=0.0.0.0",
  "--remote-allow-origins=*",
  "--user-data-dir=$ProfileDir",
  "--no-first-run",
  "--no-default-browser-check",
  "about:blank"
)
Write-Host "==> launching: $chrome $($args -join ' ')"
Start-Process -FilePath $chrome -ArgumentList $args | Out-Null

# 等 Chrome 真的开始监听
$deadline = (Get-Date).AddSeconds(30)
while ((Get-Date) -lt $deadline) {
  Start-Sleep -Milliseconds 500
  try {
    $r = Invoke-WebRequest -Uri "http://127.0.0.1:$Port/json/version" -TimeoutSec 2 -ErrorAction Stop
    Write-Host "==> Chrome up. /json/version:"
    Write-Host $r.Content
    exit 0
  } catch { }
}
Write-Error "Chrome failed to come up on $Port within 30s"
