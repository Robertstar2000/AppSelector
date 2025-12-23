# Fix IIS Site Setup for App Selector
# Run as Administrator

Write-Host "=== Fixing IIS Site Setup ===" -ForegroundColor Cyan

# Check if running as admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Import WebAdministration
Import-Module WebAdministration

# Configuration
$siteName = "AppSelector"
$appPoolName = "AppSelector"
$physicalPath = "c:\Users\BobM\TallmanApps\AppSelector\dist"
$port = 80

# Check what's currently on port 80
Write-Host "`nChecking current port 80 bindings..." -ForegroundColor Yellow
$sitesOnPort80 = Get-Website | Where-Object { $_.bindings.Collection.bindingInformation -like "*:80:*" }
if ($sitesOnPort80) {
    Write-Host "Found sites on port 80:" -ForegroundColor White
    $sitesOnPort80 | ForEach-Object {
        Write-Host "  - $($_.Name) (State: $($_.State))" -ForegroundColor White
        if ($_.Name -ne $siteName) {
            Write-Host "    Stopping site: $($_.Name)" -ForegroundColor Yellow
            Stop-Website -Name $_.Name
        }
    }
}

# Check if AppSelector site exists
Write-Host "`nChecking AppSelector site..." -ForegroundColor Yellow
$site = Get-Website -Name $siteName -ErrorAction SilentlyContinue

if ($site) {
    Write-Host "Site exists. Current state: $($site.State)" -ForegroundColor White
    Write-Host "Physical path: $($site.PhysicalPath)" -ForegroundColor White
    
    # Update physical path if needed
    if ($site.PhysicalPath -ne $physicalPath) {
        Write-Host "Updating physical path..." -ForegroundColor Yellow
        Set-ItemProperty "IIS:\Sites\$siteName" -Name physicalPath -Value $physicalPath
    }
    
    # Start the site
    Write-Host "Starting site..." -ForegroundColor Yellow
    Start-Website -Name $siteName
    
} else {
    Write-Host "Site doesn't exist. Creating..." -ForegroundColor Yellow
    
    # Create app pool if needed
    if (!(Test-Path "IIS:\AppPools\$appPoolName")) {
        New-WebAppPool -Name $appPoolName
        Set-ItemProperty "IIS:\AppPools\$appPoolName" -Name managedRuntimeVersion -Value ""
        Write-Host "App pool created" -ForegroundColor Green
    }
    
    # Create website
    New-Website -Name $siteName -PhysicalPath $physicalPath -ApplicationPool $appPoolName -Port $port -Force
    Write-Host "Website created" -ForegroundColor Green
}

# Ensure ARR is enabled at server level
Write-Host "`nConfiguring ARR..." -ForegroundColor Yellow
& "$env:windir\system32\inetsrv\appcmd.exe" set config -section:system.webServer/proxy /enabled:"True" /commit:apphost 2>$null

# Configure server variables
$serverVars = @("HTTP_X_ORIGINAL_ACCEPT_ENCODING", "HTTP_ACCEPT_ENCODING")
foreach ($var in $serverVars) {
    & "$env:windir\system32\inetsrv\appcmd.exe" set config -section:system.webServer/rewrite/allowedServerVariables /+"[name='$var']" /commit:apphost 2>$null
}
Write-Host "ARR configured" -ForegroundColor Green

# Check web.config
Write-Host "`nChecking web.config..." -ForegroundColor Yellow
$webConfigPath = Join-Path $physicalPath "web.config"
if (Test-Path $webConfigPath) {
    Write-Host "✓ web.config exists" -ForegroundColor Green
} else {
    Write-Host "✗ web.config missing!" -ForegroundColor Red
}

# Check dist folder
Write-Host "`nChecking dist folder contents..." -ForegroundColor Yellow
if (Test-Path $physicalPath) {
    $files = Get-ChildItem $physicalPath
    Write-Host "Files in dist:" -ForegroundColor White
    $files | ForEach-Object { Write-Host "  - $($_.Name)" -ForegroundColor White }
    
    if (Test-Path (Join-Path $physicalPath "index.html")) {
        Write-Host "✓ index.html found" -ForegroundColor Green
    } else {
        Write-Host "✗ index.html missing!" -ForegroundColor Red
    }
} else {
    Write-Host "✗ Physical path doesn't exist: $physicalPath" -ForegroundColor Red
}

# Restart site
Write-Host "`nRestarting website..." -ForegroundColor Yellow
Restart-WebAppPool -Name $appPoolName
Stop-Website -Name $siteName
Start-Sleep -Seconds 2
Start-Website -Name $siteName

# Wait a moment
Start-Sleep -Seconds 3

# Test
Write-Host "`nTesting website..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost/" -UseBasicParsing -TimeoutSec 5
    Write-Host "✓ Website responding! Status: $($response.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "✗ Website test failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test API proxy
Write-Host "`nTesting API proxy..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost/api/apps" -UseBasicParsing -TimeoutSec 5
    Write-Host "✓ API proxy working! Status: $($response.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "✗ API proxy failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n=== Setup Complete ===" -ForegroundColor Cyan
Write-Host "`nSite Status:" -ForegroundColor White
Get-Website -Name $siteName | Format-List Name, State, PhysicalPath, @{Name="Bindings";Expression={$_.bindings.Collection.bindingInformation}}

Write-Host "`nPress Enter to exit..." -ForegroundColor Gray
Read-Host
