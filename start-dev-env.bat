@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
title Primary English Grammar Quiz - Dev Environment

set "PROJECT_DIR=%~dp0"
set "CLOUDFLARED_PATH=C:\Users\NuoHe\AppData\Local\Microsoft\WinGet\Packages\Cloudflare.cloudflared_Microsoft.Winget.Source_8wekyb3d8bbwe\cloudflared.exe"

cd /d "%PROJECT_DIR%"

:: Check prerequisites
if not exist "%CLOUDFLARED_PATH%" (
    echo [ERROR] cloudflared not found at:
    echo         %CLOUDFLARED_PATH%
    echo.
    echo Please install it: winget install Cloudflare.cloudflared
    echo Or update CLOUDFLARED_PATH in this script.
    echo.
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

:: Step 1: Start npm run dev
echo  [1/3] Starting frontend + backend dev servers...
start "npm-run-dev" cmd /k "cd /d %PROJECT_DIR% && title npm-run-dev && npm run dev"
echo         Window: npm-run-dev
echo.

:: Step 2: Wait for Vite dev server (port 4175)
echo  [2/3] Waiting for dev server on port 4175...
echo         (This may take a moment while npm compiles...)
:wait_loop
>nul 2>&1 timeout /t 2 /nobreak
powershell -NoProfile -Command "$tcp=New-Object System.Net.Sockets.TcpClient; try{$tcp.Connect('127.0.0.1',4175); exit 0}catch{exit 1}"
if errorlevel 1 goto wait_loop
echo         Dev server is ready!
echo.

:: Step 3: Start Cloudflare Tunnel
echo  [3/3] Starting Cloudflare Tunnel...
start "cloudflared-tunnel" cmd /k "title cloudflared-tunnel & %CLOUDFLARED_PATH% tunnel --url http://localhost:4175"
echo         Window: cloudflared-tunnel
echo.

:: Done
cls
echo ====================================================================
echo    Environment Ready!
echo.
echo    Frontend : http://localhost:4175
echo    Backend  : http://localhost:4310
echo    Tunnel   : Check the cloudflared-tunnel window for the URL
echo.
echo    Close the cloudflared-tunnel or npm-run-dev windows to
echo    stop those services individually.
echo ====================================================================
echo.
echo Press any key to close this window (services will continue running)...
pause >nul
