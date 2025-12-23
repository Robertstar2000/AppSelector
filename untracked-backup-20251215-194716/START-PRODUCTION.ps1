# Start Production Environment
# Run as Administrator

Write-Host "=== STARTING PRODUCTION ENVIRONMENT ===" -ForegroundColor Cyan
Write-Host ""

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "ERROR: Must run as Administrator!" -ForegroundColor Red
    pause
    exit 1
}

Write-Host "Step 1: Killing Node.js on port 8080..." -ForegroundColor Yellow
$netstat = netstat -ano | findstr ":8080.*LISTENING"
if ($netstat) {
    $parts = $netstat -split '\s+' | Where-Object { $_ -ne '' }
    $processId = $parts[-1]
    try {
        $proc = Get-Process -Id $processId -ErrorAction Stop
        if ($proc.Name -eq "node") {
            Write-Host "  Found Node.js (PID $processId) on port 8080" -ForegroundColor Yellow
            Stop-Process -Id $processId -Force
            Start-Sleep -Seconds 3
            Write-Host "  Node.js killed!" -ForegroundColor Green
        }
    } catch {
        Write-Host "  Could not kill process: $_" -ForegroundColor Yellow
    }
} else {
    Write-Host "  Port 8080 is free" -ForegroundColor Green
}
Write-Host ""

Write-Host "Step 2: Starting IIS site on port 8080..." -ForegroundColor Yellow
try {
    Import-Module WebAdministration -ErrorAction Stop
    $site = Get-Website | Where-Object { $_.Bindings.Collection.bindingInformation -like "*:8080:*" }
    
    if ($site) {
        Start-Website -Name $site.Name
        Start-Sleep -Seconds 2
        $state = (Get-Website -Name $site.Name).State
        if ($state -eq "Started") {
            Write-Host "  IIS site started! ($($site.Name))" -ForegroundColor Green
        } else {
            Write-Host "  WARNING: Site state is $state" -ForegroundColor Yellow
        }
    } else {
        Write-Host "  No IIS site found on port 8080" -ForegroundColor Red
    }
} catch {
    Write-Host "  Error: $_" -ForegroundColor Red
}
Write-Host ""

Write-Host "Step 3: Starting backend service (port 3001)..." -ForegroundColor Yellow
try {
    $service = Get-Service -Name "AppSelectorBackend" -ErrorAction Stop
    if ($service.Status -eq "Stopped") {
        Start-Service -Name "AppSelectorBackend"
        Start-Sleep -Seconds 3
        $newStatus = (Get-Service -Name "AppSelectorBackend").Status
        Write-Host "  Backend service status: $newStatus" -ForegroundColor Green
    } else {
        Write-Host "  Backend service already running ($($service.Status))" -ForegroundColor Green
    }
} catch {
    Write-Host "  Error starting backend service: $_" -ForegroundColor Red
}
Write-Host ""

Write-Host "=== VERIFICATION ===" -ForegroundColor Cyan

# Check port 8080
$port8080 = netstat -ano | findstr ":8080.*LISTENING"
if ($port8080) {
    Write-Host "Port 8080 (Frontend): ACTIVE" -ForegroundColor Green
} else {
    Write-Host "Port 8080 (Frontend): NOT ACTIVE" -ForegroundColor Red
}

# Check port 3001
$port3001 = netstat -ano | findstr ":3001.*LISTENING"
if ($port3001) {
    Write-Host "Port 3001 (Backend): ACTIVE" -ForegroundColor Green
} else {
    Write-Host "Port 3001 (Backend): NOT ACTIVE" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== PRODUCTION READY ===" -ForegroundColor Green
Write-Host "Frontend: http://localhost:8080 (IIS serving from dist/)" -ForegroundColor Cyan
Write-Host "Backend:  http://localhost:3001 (Windows Service)" -ForegroundColor Cyan
Write-Host ""
Write-Host "To access the app, use incognito mode or disable Copilot extension" -ForegroundColor Yellow
Write-Host ""
pause
