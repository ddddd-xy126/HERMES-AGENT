@echo off
REM 构建一键启动 exe（需要本机已装 Python；优先 py 启动器避免 venv 劫持）
setlocal
cd /d "%~dp0"

set "PYEXE=py -3"
%PYEXE% --version >nul 2>&1 || set "PYEXE=python"

echo [1/2] 安装 PyInstaller（首次运行用）...
%PYEXE% -m pip install --quiet --upgrade pyinstaller || goto :error

echo [2/2] 打包 exe ...
%PYEXE% -m PyInstaller --noconfirm --onefile --console --name "StartHermesLucky" --distpath "%~dp0.." --workpath "%~dp0build" --specpath "%~dp0build" hermes_launcher.py || goto :error

echo.
echo ============================================================
echo  打包完成：%~dp0..\StartHermesLucky.exe
echo  双击该 exe 即可启动飞书 Gateway + Dashboard 并打开网页。
echo ============================================================
exit /b 0

:error
echo.
echo 构建失败，请检查上面的错误信息。
exit /b 1
