# Diagnose IIS Configuration
# Run as Administrator

Write-Host "=== IIS Configuration Diagnosis ===" -ForegroundColor Cyan

# Check if running as admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Import-Module WebAdministration

# List all websites
Write-Host "`n1. ALL IIS WEBSITES:" -ForegroundColor Yellow
Get-Website | Format-Table Name, State, @{Name="Port";Expression={($_.bindings.Collection.bindingInformation -split ':')[1]}}, PhysicalPath, ApplicationPool -AutoSize

# List all app pools
Write-Host "`n2. ALL APPLICATION POOLS:" -ForegroundColor Yellow
Get-ChildItem IIS:\AppPools | Format-Table Name, State, managedRuntimeVersion -AutoSize

# Check what's on port 80
Write-Host "`n3. SITES ON PORT 80:" -ForegroundColor Yellow
Get-Website | Where-Object { $_.bindings.Collection.bindingInformation -like "*:80:*" } | ForEach-Object {
    Write-Host "  $($_.Name) - State: $($_.State) - Path: $($_.PhysicalPath)" -ForegroundColor White
}

# Check AppSelector specifically
Write-Host "`n4. APP SELECTOR SITE DETAILS:" -ForegroundColor Yellow
$site = Get-Website -Name "AppSelector" -ErrorAction SilentlyContinue
if ($site) {
    $site | Format-List Name, State, PhysicalPath, ApplicationPool
    Write-Host "  Bindings:" -ForegroundColor White
    $site.bindings.Collection | ForEach-Object {
        Write-Host "    $($_.bindingInformation)" -ForegroundColor Gray
    }
} else {
    Write-Host "  AppSelector site NOT FOUND" -ForegroundColor Red
}

# Check WEB03 site
Write-Host "`n5. WEB03 SITE DETAILS:" -ForegroundColor Yellow
$web03 = Get-Website -Name "WEB03" -ErrorAction SilentlyContinue
if ($web03) {
    $web03 | Format-List Name, State, PhysicalPath, ApplicationPool
    Write-Host "  Bindings:" -ForegroundColor White
    $web03.bindings.Collection | ForEach-Object {
        Write-Host "    $($_.bindingInformation)" -ForegroundColor Gray
    }
} else {
    Write-Host "  WEB03 site not found" -ForegroundColor Gray
}

# Check dist folder
Write-Host "`n6. DIST FOLDER CHECK:" -ForegroundColor Yellow
$distPath = "c:\Users\BobM\TallmanApps\AppSelector\dist"
if (Test-Path $distPath) {
    Write-Host "  ✓ Dist folder exists: $distPath" -ForegroundColor Green
    Write-Host "  Contents:" -ForegroundColor White
    Get-ChildItem $distPath | ForEach-Object {
        Write-Host "    - $($_.Name)" -ForegroundColor Gray
    }
    
    if (Test-Path "$distPath\index.html") {
        Write-Host "  ✓ index.html found" -ForegroundColor Green
    } else {
        Write-Host "  ✗ index.html MISSING!" -ForegroundColor Red
    }
    
    if (Test-Path "$distPath\web.config") {
        Write-Host "  ✓ web.config found" -ForegroundColor Green
    } else {
        Write-Host "  ✗ web.config MISSING!" -ForegroundColor Red
    }
} else {
    Write-Host "  ✗ Dist folder NOT FOUND: $distPath" -ForegroundColor Red
}

# Check ARR configuration
Write-Host "`n7. ARR PROXY STATUS:" -ForegroundColor Yellow
$arrConfig = & "$env:windir\system32\inetsrv\appcmd.exe" list config -section:system.webServer/proxy
if ($arrConfig -like "*enabled=`"true`"*") {
    Write-Host "  ✓ ARR Proxy is enabled" -ForegroundColor Green
} else {
    Write-Host "  ✗ ARR Proxy is NOT enabled" -ForegroundColor Red
}

# Check backend service
Write-Host "`n8. BACKEND SERVICE:" -ForegroundColor Yellow
$service = Get-Service -Name "AppSelectorBackend" -ErrorAction SilentlyContinue
if ($service) {
    Write-Host "  Status: $($service.Status)" -ForegroundColor $(if ($service.Status -eq "Running") {"Green"} else {"Red"})
} else {
    Write-Host "  ✗ Service not found" -ForegroundColor Red
}

Write-Host "`n=== Diagnosis Complete ===" -ForegroundColor Cyan
Write-Host "`nRecommendation:" -ForegroundColor White
Write-Host "  If WEB03 is on port 80, we need to either:" -ForegroundColor Yellow
Write-Host "    1. Stop WEB03 and use AppSelector on port 80" -ForegroundColor Gray
Write-Host "    2. Move AppSelector to a different port (e.g., 8080)" -ForegroundColor Gray
Write-Host "    3. Use WEB03 as the site and point it to AppSelector dist folder" -ForegroundColor Gray
Write-Host ""
Read-Host "Press Enter to exit"
