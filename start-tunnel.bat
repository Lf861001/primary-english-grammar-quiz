@echo off
chcp 65001 >nul
title Cloudflare Tunnel - Primary English Grammar Quiz

set "CLOUDFLARED_PATH=C:\Users\NuoHe\AppData\Local\Microsoft\WinGet\Packages\Cloudflare.cloudflared_Microsoft.Winget.Source_8wekyb3d8bbwe\cloudflared.exe"

:: Check cloudflared
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

echo ====================================================================
echo    Starting Cloudflare Tunnel for localhost:4175
echo ====================================================================
echo.
echo    Make sure npm run dev is already running before
echo    starting the tunnel.
echo.
echo    The tunnel URL will appear in this window once ready.
echo ====================================================================
echo.

"%CLOUDFLARED_PATH%" tunnel --url http://localhost:4175

echo.
pause
