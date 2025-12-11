# Point WEB03 to C:\Users\BobM\TallmanApps folder
# Run as Administrator

Write-Host "=== Setting WEB03 to TallmanApps Folder ===" -ForegroundColor Cyan

# Check if running as admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Import-Module WebAdministration

$siteName = "WEB03"
$physicalPath = "C:\Users\BobM\TallmanApps"
$backendPort = 3001

# Check if WEB03 exists
Write-Host "`nChecking for WEB03 site..." -ForegroundColor Yellow
$site = Get-Website -Name $siteName -ErrorAction SilentlyContinue

if (!$site) {
    Write-Host "✗ WEB03 site not found - creating it..." -ForegroundColor Yellow
    
    # Create app pool
    if (!(Test-Path "IIS:\AppPools\$siteName")) {
        New-WebAppPool -Name $siteName
        Set-ItemProperty "IIS:\AppPools\$siteName" -Name managedRuntimeVersion -Value ""
    }
    
    # Create site
    New-Website -Name $siteName -PhysicalPath $physicalPath -ApplicationPool $siteName -Port 80 -Force
    Write-Host "✓ WEB03 site created" -ForegroundColor Green
} else {
    Write-Host "✓ WEB03 site exists" -ForegroundColor Green
    Write-Host "  Current path: $($site.PhysicalPath)" -ForegroundColor White
}

# Update physical path to TallmanApps folder
Write-Host "`nUpdating physical path to TallmanApps folder..." -ForegroundColor Yellow
Set-ItemProperty "IIS:\Sites\$siteName" -Name physicalPath -Value $physicalPath
Write-Host "✓ Physical path updated to: $physicalPath" -ForegroundColor Green

# Enable directory browsing
Write-Host "`nEnabling directory browsing..." -ForegroundColor Yellow
Set-WebConfigurationProperty -Filter /system.webServer/directoryBrowse -Name enabled -Value true -PSPath "IIS:\Sites\$siteName"
Write-Host "✓ Directory browsing enabled" -ForegroundColor Green

# Ensure ARR is enabled
Write-Host "`nConfiguring ARR..." -ForegroundColor Yellow
& "$env:windir\system32\inetsrv\appcmd.exe" set config -section:system.webServer/proxy /enabled:"True" /commit:apphost 2>$null

# Configure server variables for ARR
$serverVars = @("HTTP_X_ORIGINAL_ACCEPT_ENCODING", "HTTP_ACCEPT_ENCODING")
foreach ($var in $serverVars) {
    & "$env:windir\system32\inetsrv\appcmd.exe" set config -section:system.webServer/rewrite/allowedServerVariables /+"[name='$var']" /commit:apphost 2>$null
}
Write-Host "✓ ARR configured" -ForegroundColor Green

# Check backend service
Write-Host "`nChecking backend service..." -ForegroundColor Yellow
$service = Get-Service -Name "AppSelectorBackend" -ErrorAction SilentlyContinue
if ($service) {
    Write-Host "✓ Backend service exists: $($service.Status)" -ForegroundColor Green
    if ($service.Status -ne "Running") {
        Write-Host "  Starting service..." -ForegroundColor Yellow
        Start-Service -Name "AppSelectorBackend" -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 3
    }
} else {
    Write-Host "✗ Backend service not found" -ForegroundColor Red
}

# Restart the site
Write-Host "`nRestarting WEB03 site..." -ForegroundColor Yellow
Stop-Website -Name $siteName -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
Start-Website -Name $siteName
Start-Sleep -Seconds 3

# Show configuration
Write-Host "`n=== Configuration Complete ===" -ForegroundColor Cyan
Write-Host "`nWEB03 Site Information:" -ForegroundColor White
Get-Website -Name $siteName | Format-List Name, State, PhysicalPath, @{Name="Bindings";Expression={$_.bindings.Collection.bindingInformation}}

# Test access
Write-Host "`nTesting..." -ForegroundColor Yellow
Write-Host "  Backend: http://localhost:$backendPort/api/apps" -ForegroundColor White
try {
    $response = Invoke-WebRequest -Uri "http://localhost:$backendPort/api/apps" -UseBasicParsing -TimeoutSec 5
    Write-Host "    ✓ Backend OK ($($response.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "    ✗ Backend failed" -ForegroundColor Red
}

Write-Host "  Website: http://localhost/" -ForegroundColor White
try {
    $response = Invoke-WebRequest -Uri "http://localhost/" -UseBasicParsing -TimeoutSec 5
    Write-Host "    ✓ Website OK ($($response.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "    ✗ Website failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nYour site is now available at:" -ForegroundColor Cyan
Write-Host "  http://localhost/" -ForegroundColor White
Write-Host "`nTo access AppSelector specifically:" -ForegroundColor White
Write-Host "  http://localhost/AppSelector/" -ForegroundColor Cyan
Write-Host ""

Read-Host "Press Enter to exit"
