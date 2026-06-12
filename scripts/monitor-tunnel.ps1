param(
    [string]$LogFile = "$env:TEMP\cloudflared-tunnel.log",
    [string]$UrlOutputFile = "$PWD\tunnel-url.txt"
)

$cfPath = "C:\Users\NuoHe\AppData\Local\Microsoft\WinGet\Packages\Cloudflare.cloudflared_Microsoft.Winget.Source_8wekyb3d8bbwe\cloudflared.exe"

# Clean up old files
Remove-Item $LogFile -ErrorAction SilentlyContinue

Write-Host "[1/2] Starting Cloudflare Tunnel..." -ForegroundColor Cyan
Write-Host ""

# Start cloudflared in a new window with logging
$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = "powershell"
$psi.Arguments = "-NoExit", "-Command", "& '$cfPath' tunnel --url http://localhost:4175 --logfile '$LogFile'"
$psi.UseShellExecute = $true
$psi.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Normal
[void][System.Diagnostics.Process]::Start($psi)

# Wait for tunnel URL
Write-Host "[2/2] Waiting for tunnel URL (up to 60 seconds)..." -ForegroundColor Cyan
Write-Host "     Checking every 3 seconds..."
Write-Host ""

$timeout = 60
for ($i = 0; $i -lt $timeout; $i += 3) {
    Start-Sleep -Seconds 3
    
    if (Test-Path $LogFile) {
        $content = Get-Content $LogFile -Raw -ErrorAction SilentlyContinue
        if ($content -match '(https://[a-zA-Z0-9-]+\.trycloudflare\.com)') {
            $tunnelUrl = $matches[1]
            
            # Save URL to output file
            $tunnelUrl | Out-File -FilePath $UrlOutputFile -Encoding UTF8
            
            # Clear and show success
            Clear-Host
            Write-Host ""
            Write-Host "  =======================================================" -ForegroundColor Green
            Write-Host "       Environment Ready!" -ForegroundColor White
            Write-Host ""
            Write-Host "       Frontend : http://localhost:4175" -ForegroundColor White
            Write-Host "       Backend  : http://localhost:4310" -ForegroundColor White
            Write-Host ""
            Write-Host "       TUNNEL URL:" -ForegroundColor Yellow
            Write-Host "       $tunnelUrl" -ForegroundColor Green
            Write-Host ""
            Write-Host "       Open this URL on your phone!" -ForegroundColor Yellow
            Write-Host "  =======================================================" -ForegroundColor Green
            Write-Host ""
            Write-Host "  Close this window to exit (services keep running)." -ForegroundColor DarkGray
            Write-Host ""
            
            # Keep the window open so the user can see the URL
            Read-Host "  Press Enter to close"
            exit 0
        }
    }
}

# Timeout - show what's in the log
Clear-Host
Write-Host ""
Write-Host "  =======================================================" -ForegroundColor Red
Write-Host "       Tunnel URL not found after $timeout seconds" -ForegroundColor Red
Write-Host "       Check the cloudflared-tunnel window." -ForegroundColor Yellow
Write-Host "  =======================================================" -ForegroundColor Red
Write-Host ""
if (Test-Path $LogFile) {
    Write-Host "  Last log entries:" -ForegroundColor DarkGray
    Get-Content $LogFile -Tail 5 | ForEach-Object { Write-Host "    $_" -ForegroundColor DarkGray }
}
Write-Host ""
Read-Host "  Press Enter to close"
exit 1
