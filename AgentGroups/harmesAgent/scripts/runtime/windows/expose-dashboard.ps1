# 让局域网内同事访问 Hermes Dashboard
# 用法：用【管理员 PowerShell】打开本目录，跑：  .\_expose-dashboard.ps1
# 撤销：用【管理员 PowerShell】跑：  .\_expose-dashboard.ps1 -Remove

param(
    [int]$Port = 9119,
    [switch]$Remove
)

# 自动重新拿 WSL IP（每次 WSL 重启都会变）
$wslIp = (wsl -d Ubuntu hostname -I).Trim().Split(' ')[0]
$winIp = (Get-NetIPAddress -AddressFamily IPv4 |
    Where-Object { $_.PrefixOrigin -eq 'Dhcp' -and $_.InterfaceAlias -notlike '*WSL*' -and $_.InterfaceAlias -notlike '*vEthernet*' } |
    Select-Object -First 1).IPAddress

Write-Host ""
Write-Host "Windows 局域网 IP : $winIp" -ForegroundColor Cyan
Write-Host "WSL Ubuntu  IP   : $wslIp" -ForegroundColor Cyan
Write-Host "端口             : $Port" -ForegroundColor Cyan
Write-Host ""

if ($Remove) {
    Write-Host "→ 删除端口转发..." -ForegroundColor Yellow
    netsh interface portproxy delete v4tov4 listenport=$Port listenaddress=0.0.0.0 2>$null
    Write-Host "→ 删除防火墙规则..." -ForegroundColor Yellow
    Remove-NetFirewallRule -DisplayName "Hermes Dashboard $Port" -ErrorAction SilentlyContinue
    Write-Host "✓ 已撤销" -ForegroundColor Green
    return
}

# 先清掉旧的同端口转发规则（避免堆积）
netsh interface portproxy delete v4tov4 listenport=$Port listenaddress=0.0.0.0 2>$null | Out-Null

Write-Host "→ 添加端口转发：0.0.0.0:$Port → ${wslIp}:$Port" -ForegroundColor Yellow
netsh interface portproxy add v4tov4 listenport=$Port listenaddress=0.0.0.0 connectport=$Port connectaddress=$wslIp

Write-Host "→ 添加防火墙规则（放行入站 TCP $Port）..." -ForegroundColor Yellow
Remove-NetFirewallRule -DisplayName "Hermes Dashboard $Port" -ErrorAction SilentlyContinue
New-NetFirewallRule -DisplayName "Hermes Dashboard $Port" `
    -Direction Inbound -Action Allow -Protocol TCP -LocalPort $Port `
    -Profile Any | Out-Null

Write-Host ""
Write-Host "✓ 配置完成！" -ForegroundColor Green
Write-Host ""
Write-Host "同事请用浏览器访问：" -ForegroundColor White
Write-Host "  http://${winIp}:$Port" -ForegroundColor Cyan
Write-Host ""
Write-Host "当前 portproxy 规则：" -ForegroundColor White
netsh interface portproxy show v4tov4
