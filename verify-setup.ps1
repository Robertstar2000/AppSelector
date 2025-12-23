# Verify App Selector Setup
# Run as Administrator

Write-Host "=== App Selector Setup Verification ===" -ForegroundColor Cyan

# Check if running as admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    exit 1
}

# Import WebAdministration
Import-Module WebAdministration -ErrorAction SilentlyContinue

# Check IIS Website
Write-Host "`n1. Checking IIS Website..." -ForegroundColor Yellow
$site = Get-Website -Name AppSelector -ErrorAction SilentlyContinue
if ($site) {
    Write-Host "✓ Website 'AppSelector' exists" -ForegroundColor Green
    Write-Host "  State: $($site.State)" -ForegroundColor White
    Write-Host "  Path: $($site.PhysicalPath)" -ForegroundColor White
    Write-Host "  Bindings: $($site.bindings.Collection.bindingInformation)" -ForegroundColor White
} else {
    Write-Host "✗ Website 'AppSelector' not found" -ForegroundColor Red
}

# Check Backend Service
Write-Host "`n2. Checking Backend Service..." -ForegroundColor Yellow
$service = Get-Service -Name AppSelectorBackend -ErrorAction SilentlyContinue
if ($service) {
    Write-Host "✓ Service 'AppSelectorBackend' exists" -ForegroundColor Green
    Write-Host "  Status: $($service.Status)" -ForegroundColor White
    
    if ($service.Status -ne "Running") {
        Write-Host "  Attempting to start service..." -ForegroundColor Yellow
        try {
            Start-Service -Name AppSelectorBackend
            Start-Sleep -Seconds 3
            $service.Refresh()
            if ($service.Status -eq "Running") {
                Write-Host "  ✓ Service started successfully!" -ForegroundColor Green
            } else {
                Write-Host "  ✗ Service failed to start" -ForegroundColor Red
            }
        } catch {
            Write-Host "  ✗ Error starting service: $_" -ForegroundColor Red
        }
    }
} else {
    Write-Host "✗ Service 'AppSelectorBackend' not found" -ForegroundColor Red
}

# Test Backend
Write-Host "`n3. Testing Backend (http://localhost:3001/api/apps)..." -ForegroundColor Yellow
Start-Sleep -Seconds 2
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3001/api/apps" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    if ($response.StatusCode -eq 200) {
        Write-Host "✓ Backend is responding! ($($response.StatusCode))" -ForegroundColor Green
        $apps = ($response.Content | ConvertFrom-Json)
        Write-Host "  Found $($apps.Count) apps in database" -ForegroundColor White
    }
} catch {
    Write-Host "✗ Backend not responding: $($_.Exception.Message)" -ForegroundColor Red
}

# Test IIS Proxy
Write-Host "`n4. Testing IIS Proxy (http://localhost/api/apps)..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost/api/apps" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    if ($response.StatusCode -eq 200) {
        Write-Host "✓ IIS proxy is working! ($($response.StatusCode))" -ForegroundColor Green
    }
} catch {
    Write-Host "✗ IIS proxy failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test Frontend
Write-Host "`n5. Testing Frontend (http://localhost/)..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost/" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    if ($response.StatusCode -eq 200 -and $response.Content -like "*<!DOCTYPE html>*") {
        Write-Host "✓ Frontend is serving! ($($response.StatusCode))" -ForegroundColor Green
    }
} catch {
    Write-Host "✗ Frontend failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n=== Verification Complete ===" -ForegroundColor Cyan
Write-Host "`nIf all tests passed, your app is ready at:" -ForegroundColor White
Write-Host "  http://localhost/" -ForegroundColor Cyan
Write-Host ""
