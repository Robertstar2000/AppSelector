# Find what process is using port 8080
Write-Host "=== FINDING PROCESS USING PORT 8080 ===" -ForegroundColor Cyan
Write-Host ""

# Get netstat output for port 8080
$netstatOutput = netstat -ano | findstr ":8080"
Write-Host "Port 8080 connections:"
Write-Host $netstatOutput
Write-Host ""

# Extract PIDs
$lines = $netstatOutput -split "`n"
$processIds = @()

foreach ($line in $lines) {
    if ($line -match "LISTENING") {
        $parts = $line -split '\s+' | Where-Object { $_ -ne '' }
        $processId = $parts[-1]
        if ($processId -match '^\d+$') {
            $processIds += $processId
        }
    }
}

if ($processIds.Count -gt 0) {
    Write-Host "Process(es) using port 8080:" -ForegroundColor Yellow
    foreach ($processId in ($processIds | Select-Object -Unique)) {
        try {
            $process = Get-Process -Id $processId -ErrorAction Stop
            Write-Host "  PID: $processId" -ForegroundColor White
            Write-Host "  Name: $($process.Name)" -ForegroundColor White
            Write-Host "  Path: $($process.Path)" -ForegroundColor White
            Write-Host ""
            
            # Check if it's IIS worker process
            if ($process.Name -eq "w3wp") {
                Write-Host "  This is IIS Worker Process" -ForegroundColor Green
            } elseif ($process.Name -eq "node") {
                Write-Host "  This is Node.js (possibly Vite dev server)" -ForegroundColor Yellow
                Write-Host "  If you ran 'npm run dev', that uses port 3110, not 8080" -ForegroundColor Yellow
            } else {
                Write-Host "  This is NOT IIS!" -ForegroundColor Red
                Write-Host "  To free port 8080, kill this process:" -ForegroundColor Yellow
                Write-Host "  taskkill /PID $processId /F" -ForegroundColor Cyan
            }
        } catch {
            Write-Host "  Could not get process info for PID $processId" -ForegroundColor Red
        }
    }
} else {
    Write-Host "No process found listening on port 8080" -ForegroundColor Red
}

Write-Host ""
pause
