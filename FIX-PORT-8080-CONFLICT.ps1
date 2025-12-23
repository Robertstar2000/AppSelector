# Fix Port 8080 Conflict - Kill Node.js and Start IIS
# Run as Administrator

Write-Host "=== FIX PORT 8080 CONFLICT ===" -ForegroundColor Cyan
Write-Host ""

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "ERROR: Must run as Administrator!" -ForegroundColor Red
    pause
    exit 1
}

# Find process using port 8080
$netstatOutput = netstat -ano | findstr ":8080.*LISTENING"
Write-Host "Port 8080 status:" -ForegroundColor Yellow
Write-Host $netstatOutput
Write-Host ""

$processId = $null
if ($netstatOutput) {
    $parts = $netstatOutput -split '\s+' | Where-Object { $_ -ne '' }
    $processId = $parts[-1]
}

if ($processId) {
    try {
        $process = Get-Process -Id $processId -ErrorAction Stop
        Write-Host "Process using port 8080:" -ForegroundColor Yellow
        Write-Host "  PID: $processId"
        Write-Host "  Name: $($process.Name)"
        Write-Host ""
        
        if ($process.Name -eq "node") {
            Write-Host "This is Node.js blocking IIS!" -ForegroundColor Red
            Write-Host "Killing Node.js process..." -ForegroundColor Yellow
            
            Stop-Process -Id $processId -Force
            Start-Sleep -Seconds 3
            
            Write-Host "Node.js process killed!" -ForegroundColor Green
        } else {
            Write-Host "Killing process $($process.Name)..." -ForegroundColor Yellow
            Stop-Process -Id $processId -Force
            Start-Sleep -Seconds 3
            Write-Host "Process killed!" -ForegroundColor Green
        }
    } catch {
        Write-Host "Error killing process: $_" -ForegroundColor Red
    }
} else {
    Write-Host "No process found on port 8080" -ForegroundColor Green
}

Write-Host ""
Write-Host "Starting IIS site..." -ForegroundColor Yellow

try {
    Import-Module WebAdministration -ErrorAction Stop
    $site = Get-Website | Where-Object { $_.Bindings.Collection.bindingInformation -like "*:8080:*" }
    
    if ($site) {
        Start-Website -Name $site.Name
        Start-Sleep -Seconds 2
        
        $state = (Get-Website -Name $site.Name).State
        if ($state -eq "Started") {
            Write-Host "SUCCESS! IIS site is now running on port 8080!" -ForegroundColor Green
            Write-Host ""
            Write-Host "You can now access: http://localhost:8080" -ForegroundColor Cyan
        } else {
            Write-Host "WARNING: Site state is: $state" -ForegroundColor Yellow
        }
    } else {
        Write-Host "No IIS site found on port 8080" -ForegroundColor Red
    }
} catch {
    Write-Host "Error starting IIS site: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== NEXT STEPS ===" -ForegroundColor Cyan
Write-Host "1. Clear your browser cache (Ctrl+Shift+Delete)" -ForegroundColor White
Write-Host "2. Navigate to http://localhost:8080" -ForegroundColor White
Write-Host "3. Press Ctrl+F5 (hard refresh)" -ForegroundColor White
Write-Host ""
pause
