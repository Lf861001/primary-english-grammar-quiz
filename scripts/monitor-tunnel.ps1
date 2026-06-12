param(
    [string]$LogFile = "$env:TEMP\cloudflared-tunnel.log",
    [string]$UrlOutputFile = "$PWD\tunnel-url.txt"
)

$cfPath = "C:\Users\NuoHe\AppData\Local\Microsoft\WinGet\Packages\Cloudflare.cloudflared_Microsoft.Winget.Source_8wekyb3d8bbwe\cloudflared.exe"

# Clean up old files
Remove-Item $LogFile -ErrorAction SilentlyContinue

Write-Host "[1/3] Starting Cloudflare Tunnel..." -ForegroundColor Cyan
Write-Host ""

# Start cloudflared in a new window with logging
$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = "powershell"
$psi.Arguments = "-NoExit", "-Command", "& '$cfPath' tunnel --url http://localhost:4175 --logfile '$LogFile'"
$psi.UseShellExecute = $true
$psi.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Normal
[void][System.Diagnostics.Process]::Start($psi)

# Step 1: Wait for tunnel URL to be assigned
Write-Host "[2/3] Waiting for tunnel URL..." -ForegroundColor Cyan
Write-Host "     (unreliable network - may need retries)"
Write-Host ""

$tunnelUrl = $null
$timeout = 60
for ($i = 0; $i -lt $timeout; $i += 3) {
    Start-Sleep -Seconds 3
    
    if (Test-Path $LogFile) {
        $content = Get-Content $LogFile -Raw -ErrorAction SilentlyContinue
        if (-not $tunnelUrl -and $content -match '(https://[a-zA-Z0-9-]+\.trycloudflare\.com)') {
            $tunnelUrl = $matches[1]
            Write-Host "     URL assigned: $tunnelUrl" -ForegroundColor Green
            Write-Host ""
            Write-Host "[3/3] Waiting for connection to stabilize..." -ForegroundColor Cyan
        }

        if ($tunnelUrl -and $content -match "Registered tunnel connection") {
            # Tunnel is stable! Show success
            $tunnelUrl | Out-File -FilePath $UrlOutputFile -Encoding UTF8
            
            Clear-Host
            Write-Host ""
            Write-Host "  =======================================================" -ForegroundColor Green
            Write-Host "       Environment Ready!" -ForegroundColor White
            Write-Host ""
            Write-Host "       Frontend : http://localhost:4175" -ForegroundColor White
            Write-Host "       Backend  : http://localhost:4310" -ForegroundColor White
            Write-Host ""
            Write-Host "       TUNNEL URL (open on phone 5G):" -ForegroundColor Yellow
            Write-Host "       $tunnelUrl" -ForegroundColor Green
            Write-Host ""
            Write-Host "       Tunnel is connected to Cloudflare edge!" -ForegroundColor White
            Write-Host "       Keep all windows open while using." -ForegroundColor DarkGray
            Write-Host ""
            Write-Host "       Note: If you close VPN later, tunnel may break." -ForegroundColor DarkYellow
            Write-Host "             Just re-run this script if needed." -ForegroundColor DarkYellow
            Write-Host "  =======================================================" -ForegroundColor Green
            Write-Host ""
            Write-Host "  Close this window to exit (services keep running)." -ForegroundColor DarkGray
            Write-Host ""
            Read-Host "  Press Enter to close"
            exit 0
        }
        
        if ($tunnelUrl) {
            Write-Host "  ... waiting for stable connection ($($i+3)s)" -NoNewline
            $content | Select-String "Retrying connection" -AllMatches | Select-Object -Last 1 | ForEach-Object {
                Write-Host " [retrying...]" -ForegroundColor Yellow
            }
            if (-not ($content -match "Retrying")) { Write-Host "" }
        }
    }
}

# Timeout / Show the URL even if not fully stable
Clear-Host
if ($tunnelUrl) {
    $tunnelUrl | Out-File -FilePath $UrlOutputFile -Encoding UTF8
    Write-Host ""
    Write-Host "  =======================================================" -ForegroundColor Yellow
    Write-Host "       Tunnel URL found but connection not fully stable." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "       URL: $tunnelUrl" -ForegroundColor Green
    Write-Host ""
    Write-Host "       Try opening it on your phone anyway." -ForegroundColor White
    Write-Host "       If it doesn't work, close and re-run." -ForegroundColor White
    Write-Host "  =======================================================" -ForegroundColor Yellow
} else {
    Write-Host ""
    Write-Host "  =======================================================" -ForegroundColor Red
    Write-Host "       Tunnel URL not found after $timeout seconds" -ForegroundColor Red
    Write-Host "       Network may be blocking Cloudflare." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "       Try alternative methods:" -ForegroundColor White
    Write-Host "       1. Disconnect and reconnect VPN" -ForegroundColor White
    Write-Host "       2. Switch to a different network" -ForegroundColor White
    Write-Host "       3. Use ngrok instead: npx ngrok http 4175" -ForegroundColor White
    Write-Host "  =======================================================" -ForegroundColor Red
}
Write-Host ""
Read-Host "  Press Enter to close"
exit 1
