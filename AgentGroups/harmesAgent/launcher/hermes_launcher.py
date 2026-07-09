"""
爱马仕 Lucky 一键启动器
- 通过 WSL Ubuntu 启动 Hermes Gateway 与 Dashboard
- 等待 Dashboard (http://localhost:9119) 就绪后自动打开浏览器
"""
from __future__ import annotations

import socket
import subprocess
import sys
import time
import webbrowser

# 注意：使用 WSL 内的 POSIX 路径
WSL_DISTRO = "Ubuntu"
SCRIPT_DIR_WSL = "/mnt/d/project/hermes-agent/AgentGroups/harmesAgent/scripts/runtime"
GATEWAY_SCRIPT = f"{SCRIPT_DIR_WSL}/start-gateway.sh"
DASHBOARD_SCRIPT = f"{SCRIPT_DIR_WSL}/start-dashboard.sh"
DASHBOARD_URL = "http://localhost:9119"
DASHBOARD_PORT = 9119
WAIT_SECONDS = 60


def run_wsl(script_path: str) -> tuple[int, str]:
    """同步执行一段 WSL bash 脚本，返回 (returncode, 合并输出)。"""
    cmd = ["wsl.exe", "-d", WSL_DISTRO, "--", "bash", script_path]
    try:
        proc = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace",
            timeout=120,
        )
        return proc.returncode, (proc.stdout or "") + (proc.stderr or "")
    except FileNotFoundError:
        return 127, "未找到 wsl.exe，请确认 Windows 已启用 WSL2。"
    except subprocess.TimeoutExpired:
        return 124, "WSL 命令超时。"


def port_open(host: str, port: int, timeout: float = 1.0) -> bool:
    try:
        with socket.create_connection((host, port), timeout=timeout):
            return True
    except OSError:
        return False


def wait_for_dashboard(max_seconds: int = WAIT_SECONDS) -> bool:
    print(f"⏳ 等待 Dashboard 端口 {DASHBOARD_PORT} 就绪 ...")
    start = time.monotonic()
    while time.monotonic() - start < max_seconds:
        if port_open("127.0.0.1", DASHBOARD_PORT) or port_open("localhost", DASHBOARD_PORT):
            return True
        time.sleep(1)
    return False


def banner(text: str) -> None:
    print("\n" + "=" * 60)
    print(text)
    print("=" * 60)


def main() -> int:
    banner("🐶 爱马仕 Lucky · 一键启动")

    print("\n[1/3] 启动 Gateway（飞书机器人后端）...")
    rc, out = run_wsl(GATEWAY_SCRIPT)
    print(out)
    if rc != 0:
        print(f"⚠️  Gateway 脚本退出码 {rc}，继续尝试 Dashboard。")

    print("\n[2/3] 启动 Dashboard（爱马仕站点 Web 控制台）...")
    rc2, out2 = run_wsl(DASHBOARD_SCRIPT)
    print(out2)
    if rc2 != 0:
        print(f"⚠️  Dashboard 脚本退出码 {rc2}。")

    print("\n[3/3] 打开浏览器 ...")
    if wait_for_dashboard():
        print(f"✅ Dashboard 已就绪：{DASHBOARD_URL}")
        try:
            webbrowser.open(DASHBOARD_URL, new=2)
        except Exception as exc:
            print(f"⚠️  无法自动打开浏览器：{exc}")
            print(f"   请手动访问：{DASHBOARD_URL}")
    else:
        print(f"❌ 等待 {WAIT_SECONDS}s 后端口仍未就绪。")
        print("   排查：wsl -d Ubuntu -- bash -lc 'tail -40 ~/.hermes/logs/dashboard.log'")
        print(f"   稍后可手动访问：{DASHBOARD_URL}")

    banner("完成。按回车键退出窗口。")
    try:
        input()
    except EOFError:
        pass
    return 0


if __name__ == "__main__":
    sys.exit(main())
