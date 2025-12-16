# Setup IIS website with ARR proxy for AppSelector
# Run this as Administrator

Write-Host "=== App Selector IIS Setup ===" -ForegroundColor Cyan

# Configuration
$siteName = "AppSelector"
$appPoolName = "AppSelector"
$physicalPath = "c:\Users\BobM\TallmanApps\AppSelector\dist"
$port = 80
$backendPort = 3001

# Stop any existing Node processes
Write-Host "`nStopping existing Node processes..." -ForegroundColor Yellow
Get-Process -Name node -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

# Import WebAdministration module
Import-Module WebAdministration -ErrorAction SilentlyContinue

# Create Application Pool if it doesn't exist
Write-Host "`nCreating Application Pool: $appPoolName" -ForegroundColor Yellow
if (!(Test-Path "IIS:\AppPools\$appPoolName")) {
    New-WebAppPool -Name $appPoolName
    Set-ItemProperty "IIS:\AppPools\$appPoolName" -Name managedRuntimeVersion -Value ""
    Write-Host "Application Pool created successfully" -ForegroundColor Green
} else {
    Write-Host "Application Pool already exists" -ForegroundColor Green
}

# Remove existing site if it exists
Write-Host "`nChecking for existing site: $siteName" -ForegroundColor Yellow
if (Test-Path "IIS:\Sites\$siteName") {
    Remove-Website -Name $siteName
    Write-Host "Existing site removed" -ForegroundColor Green
}

# Create new website
Write-Host "`nCreating website: $siteName" -ForegroundColor Yellow
New-Website -Name $siteName -PhysicalPath $physicalPath -ApplicationPool $appPoolName -Port $port -Force
Write-Host "Website created successfully on port $port" -ForegroundColor Green

# Enable ARR Server Variables
Write-Host "`nConfiguring ARR Server Variables..." -ForegroundColor Yellow
$serverVars = @("HTTP_X_ORIGINAL_ACCEPT_ENCODING", "HTTP_ACCEPT_ENCODING")
foreach ($var in $serverVars) {
    & "$env:windir\system32\inetsrv\appcmd.exe" set config -section:system.webServer/rewrite/allowedServerVariables /+"[name='$var']" /commit:apphost 2>$null
}
Write-Host "Server variables configured" -ForegroundColor Green

# Enable ARR Proxy
Write-Host "`nEnabling ARR Proxy..." -ForegroundColor Yellow
& "$env:windir\system32\inetsrv\appcmd.exe" set config -section:system.webServer/proxy /enabled:"True" /commit:apphost
Write-Host "ARR Proxy enabled" -ForegroundColor Green

# Install and start the backend service
Write-Host "`nInstalling backend service..." -ForegroundColor Yellow
$nssmPath = "C:\nssm\nssm-2.24\win64\nssm.exe"
$nodePath = "C:\Program Files\nodejs\node.exe"
$serverPath = "c:\Users\BobM\TallmanApps\AppSelector\backend\server.cjs"
$workingDir = "c:\Users\BobM\TallmanApps\AppSelector"

# Remove existing service if present
& $nssmPath stop AppSelectorBackend 2>$null
& $nssmPath remove AppSelectorBackend confirm 2>$null
Start-Sleep -Seconds 2

# Install new service
& $nssmPath install AppSelectorBackend $nodePath $serverPath
& $nssmPath set AppSelectorBackend AppDirectory $workingDir
& $nssmPath set AppSelectorBackend DisplayName "App Selector Backend"
& $nssmPath set AppSelectorBackend Description "Backend service for the App Selector application"
& $nssmPath set AppSelectorBackend Start SERVICE_AUTO_START

Write-Host "Backend service installed" -ForegroundColor Green

# Start the service
Write-Host "`nStarting backend service..." -ForegroundColor Yellow
Start-Sleep -Seconds 2
& $nssmPath start AppSelectorBackend
Start-Sleep -Seconds 3

# Check service status
$service = Get-Service -Name AppSelectorBackend -ErrorAction SilentlyContinue
if ($service -and $service.Status -eq "Running") {
    Write-Host "Backend service is running!" -ForegroundColor Green
} else {
    Write-Host "Warning: Backend service may not have started properly" -ForegroundColor Red
}

# Restart IIS
Write-Host "`nRestarting IIS..." -ForegroundColor Yellow
iisreset /noforce
Write-Host "IIS restarted" -ForegroundColor Green

# Test backend
Write-Host "`nTesting backend (http://localhost:$backendPort/api/apps)..." -ForegroundColor Yellow
Start-Sleep -Seconds 2
try {
    $response = Invoke-WebRequest -Uri "http://localhost:$backendPort/api/apps" -UseBasicParsing -TimeoutSec 5
    if ($response.StatusCode -eq 200) {
        Write-Host "✓ Backend is responding!" -ForegroundColor Green
    }
} catch {
    Write-Host "✗ Backend test failed: $_" -ForegroundColor Red
}

# Test IIS proxy
Write-Host "`nTesting IIS proxy (http://localhost/api/apps)..." -ForegroundColor Yellow
Start-Sleep -Seconds 2
try {
    $response = Invoke-WebRequest -Uri "http://localhost/api/apps" -UseBasicParsing -TimeoutSec 5
    if ($response.StatusCode -eq 200) {
        Write-Host "✓ IIS proxy is working!" -ForegroundColor Green
    }
} catch {
    Write-Host "✗ IIS proxy test failed: $_" -ForegroundColor Red
}

# Test frontend
Write-Host "`nTesting frontend (http://localhost/)..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost/" -UseBasicParsing -TimeoutSec 5
    if ($response.StatusCode -eq 200 -and $response.Content -like "*<!DOCTYPE html>*") {
        Write-Host "✓ Frontend is serving!" -ForegroundColor Green
    }
} catch {
    Write-Host "✗ Frontend test failed: $_" -ForegroundColor Red
}

Write-Host "`n=== Setup Complete ===" -ForegroundColor Cyan
Write-Host "`nYour App Selector is available at:" -ForegroundColor White
Write-Host "  http://localhost/" -ForegroundColor Cyan
Write-Host "`nBackend API available at:" -ForegroundColor White
Write-Host "  http://localhost/api/apps" -ForegroundColor Cyan
Write-Host "`nService Status:" -ForegroundColor White
Get-Service -Name AppSelectorBackend | Format-Table -AutoSize
Write-Host ""
