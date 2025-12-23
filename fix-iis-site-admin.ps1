# FIX IIS SITE - MUST RUN AS ADMINISTRATOR
# This script will configure/fix the IIS site for AppSelector

# Check if running as admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "`nERROR: This script MUST be run as Administrator!" -ForegroundColor Red
    Write-Host "Right-click PowerShell and select 'Run as Administrator', then run this script again.`n" -ForegroundColor Yellow
    exit 1
}

Write-Host "`n=== FIX IIS SITE FOR APPSELECTOR ===" -ForegroundColor Cyan

# Import WebAdministration module
try {
    Import-Module WebAdministration -ErrorAction Stop
    Write-Host "[OK] WebAdministration module loaded" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Cannot load WebAdministration module: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

$distPath = "C:\Users\BobM\TallmanApps\AppSelector\dist"
$siteName = "AppSelector"
$appPoolName = "AppSelector"

# Verify dist folder exists
Write-Host "`n1. Verifying dist folder..." -ForegroundColor Yellow
if (Test-Path $distPath) {
    Write-Host "   [OK] Dist folder exists: $distPath" -ForegroundColor Green
    Write-Host "   Contents:" -ForegroundColor Gray
    Get-ChildItem $distPath | ForEach-Object {
        Write-Host "     - $($_.Name)" -ForegroundColor Gray
    }
} else {
    Write-Host "   [ERROR] Dist folder not found: $distPath" -ForegroundColor Red
    exit 1
}

# Check if site exists
Write-Host "`n2. Checking IIS site..." -ForegroundColor Yellow
$site = Get-Website -Name $siteName -ErrorAction SilentlyContinue

if ($site) {
    Write-Host "   [OK] Site '$siteName' exists" -ForegroundColor Green
    Write-Host "   Current Physical Path: $($site.PhysicalPath)" -ForegroundColor Gray
    Write-Host "   Current State: $($site.State)" -ForegroundColor Gray
    Write-Host "   Bindings: $($site.Bindings.Collection.bindingInformation)" -ForegroundColor Gray
    
    # Update physical path if incorrect
    if ($site.PhysicalPath -ne $distPath) {
        Write-Host "`n   Updating physical path..." -ForegroundColor Yellow
        Set-ItemProperty "IIS:\Sites\$siteName" -Name physicalPath -Value $distPath
        Write-Host "   [OK] Physical path updated to: $distPath" -ForegroundColor Green
    } else {
        Write-Host "   [OK] Physical path is correct" -ForegroundColor Green
    }
    
    # Start site if stopped
    if ($site.State -ne "Started") {
        Write-Host "`n   Starting site..." -ForegroundColor Yellow
        Start-Website -Name $siteName
        Write-Host "   [OK] Site started" -ForegroundColor Green
    } else {
        Write-Host "   [OK] Site is already running" -ForegroundColor Green
    }
    
} else {
    Write-Host "   [MISSING] Site '$siteName' does not exist. Creating it..." -ForegroundColor Yellow
    
    # Check/Create Application Pool
    $appPool = Get-Item "IIS:\AppPools\$appPoolName" -ErrorAction SilentlyContinue
    if (-not $appPool) {
        Write-Host "   Creating Application Pool '$appPoolName'..." -ForegroundColor Yellow
        New-WebAppPool -Name $appPoolName
        Set-ItemProperty "IIS:\AppPools\$appPoolName" -Name managedRuntimeVersion -Value ""
        Write-Host "   [OK] Application Pool created (No Managed Code)" -ForegroundColor Green
    }
    
    # Create the website
    Write-Host "   Creating Website '$siteName'..." -ForegroundColor Yellow
    New-Website -Name $siteName -PhysicalPath $distPath -ApplicationPool $appPoolName -Port 8080
    Write-Host "   [OK] Website created on port 8080" -ForegroundColor Green
}

# Verify site after changes
Write-Host "`n3. Verifying final configuration..." -ForegroundColor Yellow
$site = Get-Website -Name $siteName
Write-Host "   Site Name: $($site.Name)" -ForegroundColor Cyan
Write-Host "   Physical Path: $($site.PhysicalPath)" -ForegroundColor White
Write-Host "   State: $($site.State)" -ForegroundColor White
Write-Host "   Bindings: $($site.Bindings.Collection.bindingInformation)" -ForegroundColor White

# Check Application Pool
$appPool = Get-Item "IIS:\AppPools\$appPoolName" -ErrorAction SilentlyContinue
if ($appPool) {
    Write-Host "`n   Application Pool:" -ForegroundColor Cyan
    Write-Host "   Name: $($appPool.Name)" -ForegroundColor White
    Write-Host "   State: $($appPool.State)" -ForegroundColor White
    Write-Host "   .NET Version: $($appPool.managedRuntimeVersion)" -ForegroundColor White
    
    # Start app pool if stopped
    if ($appPool.State -ne "Started") {
        Write-Host "   Starting Application Pool..." -ForegroundColor Yellow
        Start-WebAppPool -Name $appPoolName
        Write-Host "   [OK] Application Pool started" -ForegroundColor Green
    }
}

# Test the site
Write-Host "`n=== SITE READY ===" -ForegroundColor Green
Write-Host "Your AppSelector site should now be accessible at:" -ForegroundColor White

foreach ($binding in $site.Bindings.Collection) {
    $protocol = $binding.protocol
    $bindingInfo = $binding.bindingInformation
    $parts = $bindingInfo -split ':'
    $ip = $parts[0]
    $port = $parts[1]
    
    if ($ip -eq "" -or $ip -eq "*") {
        Write-Host "  ${protocol}://localhost:${port}" -ForegroundColor Cyan
    } else {
        Write-Host "  ${protocol}://${ip}:${port}" -ForegroundColor Cyan
    }
}

Write-Host "`nIf you're still getting 404 errors, check:" -ForegroundColor Yellow
Write-Host "1. You're using the correct URL (see above)" -ForegroundColor White
Write-Host "2. Windows Firewall allows the port" -ForegroundColor White
Write-Host "3. Check IIS logs: C:\inetpub\logs\LogFiles\" -ForegroundColor White
