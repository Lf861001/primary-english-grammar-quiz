@echo off
chcp 65001 >nul
title Primary English Grammar Quiz - Dev Environment

set "PROJECT_DIR=%~dp0"
set "CLOUDFLARED_PATH=C:\Users\NuoHe\AppData\Local\Microsoft\WinGet\Packages\Cloudflare.cloudflared_Microsoft.Winget.Source_8wekyb3d8bbwe\cloudflared.exe"
set "MONITOR_SCRIPT=%PROJECT_DIR%scripts\monitor-tunnel.ps1"
set "PROMPT_SCRIPT=%PROJECT_DIR%scripts\prompt-api-key.ps1"

cd /d "%PROJECT_DIR%"

:: Check prerequisites
if not exist "%CLOUDFLARED_PATH%" (
    echo [ERROR] cloudflared not found at:
    echo         %CLOUDFLARED_PATH%
    echo.
    echo Please install it: winget install Cloudflare.cloudflared
    pause
    exit /b 1
)

if not exist "%PROJECT_DIR%\package.json" (
    echo [ERROR] package.json not found in project directory.
    echo         Make sure this script is in the project root.
    echo.
    pause
    exit /b 1
)

:intro
cls
echo ====================================================================
echo    Primary English Grammar Quiz - Dev Environment
echo ====================================================================
echo.

:: Optional API key prompt
if exist "%PROMPT_SCRIPT%" (
    echo  [0/3] Optional AI API Key setup...
    powershell -NoProfile -ExecutionPolicy Bypass -File "%PROMPT_SCRIPT%" -ProjectDir "%PROJECT_DIR%"
    echo.
)

:: Step 1: Start npm run dev
echo  [1/3] Starting npm run dev...
start "npm-run-dev" cmd /k "title npm-run-dev && cd /d %PROJECT_DIR% && npm run dev"
echo         Window: npm-run-dev
echo.

:: Step 2: Wait for Vite dev server (port 4175)
echo  [2/3] Waiting for dev server on port 4175...
:wait_loop
>nul 2>&1 timeout /t 2 /nobreak
powershell -NoProfile -Command "$tcp=New-Object System.Net.Sockets.TcpClient; try{$tcp.Connect('127.0.0.1',4175); exit 0}catch{exit 1}"
if errorlevel 1 (
    title Dev Server: waiting...
    goto wait_loop
)
title Dev Server: READY
echo         Dev server is ready!
echo.

:: Step 3: Launch monitor script (starts tunnel + captures URL)
echo  [3/3] Starting tunnel and waiting for public URL...
echo         (This may take ~15-30 seconds)
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%MONITOR_SCRIPT%"

:: If we get here, the monitor window was closed
echo.
echo Monitor closed. Services may still be running.
echo Close the npm-run-dev and cloudflared-tunnel windows to stop them.
pause >nul
