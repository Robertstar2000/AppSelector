# Configure existing WEB03 site for App Selector
# Run as Administrator

Write-Host "=== Configuring WEB03 for App Selector ===" -ForegroundColor Cyan

# Check if running as admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Import-Module WebAdministration

$siteName = "WEB03"
$physicalPath = "c:\Users\BobM\TallmanApps\AppSelector\dist"
$backendPort = 3001

# Check if WEB03 exists
Write-Host "`nChecking for WEB03 site..." -ForegroundColor Yellow
$site = Get-Website -Name $siteName -ErrorAction SilentlyContinue

if (!$site) {
    Write-Host "✗ WEB03 site not found!" -ForegroundColor Red
    Write-Host "Creating WEB03 site..." -ForegroundColor Yellow
    
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
    Write-Host "  State: $($site.State)" -ForegroundColor White
}

# Update physical path
Write-Host "`nUpdating physical path to App Selector dist folder..." -ForegroundColor Yellow
Set-ItemProperty "IIS:\Sites\$siteName" -Name physicalPath -Value $physicalPath
Write-Host "✓ Physical path updated to: $physicalPath" -ForegroundColor Green

# Ensure ARR is enabled
Write-Host "`nConfiguring ARR..." -ForegroundColor Yellow
& "$env:windir\system32\inetsrv\appcmd.exe" set config -section:system.webServer/proxy /enabled:"True" /commit:apphost 2>$null

# Configure server variables
$serverVars = @("HTTP_X_ORIGINAL_ACCEPT_ENCODING", "HTTP_ACCEPT_ENCODING")
foreach ($var in $serverVars) {
    & "$env:windir\system32\inetsrv\appcmd.exe" set config -section:system.webServer/rewrite/allowedServerVariables /+"[name='$var']" /commit:apphost 2>$null
}
Write-Host "✓ ARR configured" -ForegroundColor Green

# Check backend service
Write-Host "`nChecking backend service..." -ForegroundColor Yellow
$service = Get-Service -Name "AppSelectorBackend" -ErrorAction SilentlyContinue
if ($service) {
    if ($service.Status -ne "Running") {
        Write-Host "  Starting backend service..." -ForegroundColor Yellow
        Start-Service -Name "AppSelectorBackend"
        Start-Sleep -Seconds 3
        $service.Refresh()
    }
    Write-Host "✓ Backend service status: $($service.Status)" -ForegroundColor Green
} else {
    Write-Host "✗ Backend service not found - installing..." -ForegroundColor Yellow
    
    $nssmPath = "C:\nssm\nssm-2.24\win64\nssm.exe"
    $nodePath = "C:\Program Files\nodejs\node.exe"
    $serverPath = "c:\Users\BobM\TallmanApps\AppSelector\backend\server.cjs"
    $workingDir = "c:\Users\BobM\TallmanApps\AppSelector"
    
    # Install service
    & $nssmPath install AppSelectorBackend $nodePath $serverPath 2>$null
    & $nssmPath set AppSelectorBackend AppDirectory $workingDir 2>$null
    & $nssmPath set AppSelectorBackend DisplayName "App Selector Backend" 2>$null
    & $nssmPath set AppSelectorBackend Start SERVICE_AUTO_START 2>$null
    
    Start-Sleep -Seconds 2
    & $nssmPath start AppSelectorBackend 2>$null
    Start-Sleep -Seconds 3
    
    Write-Host "✓ Backend service installed and started" -ForegroundColor Green
}

# Restart the site
Write-Host "`nRestarting WEB03 site..." -ForegroundColor Yellow
Stop-Website -Name $siteName -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
Start-Website -Name $siteName
Start-Sleep -Seconds 3

# Test backend directly
Write-Host "`nTesting backend (http://localhost:$backendPort/api/apps)..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:$backendPort/api/apps" -UseBasicParsing -TimeoutSec 5
    if ($response.StatusCode -eq 200) {
        Write-Host "✓ Backend responding ($($response.StatusCode))" -ForegroundColor Green
        $apps = ($response.Content | ConvertFrom-Json)
        Write-Host "  Found $($apps.Count) apps" -ForegroundColor White
    }
} catch {
    Write-Host "✗ Backend failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test frontend
Write-Host "`nTesting frontend (http://localhost/)..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost/" -UseBasicParsing -TimeoutSec 5
    if ($response.StatusCode -eq 200) {
        Write-Host "✓ Frontend responding ($($response.StatusCode))" -ForegroundColor Green
    }
} catch {
    Write-Host "✗ Frontend failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test API proxy
Write-Host "`nTesting API proxy (http://localhost/api/apps)..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost/api/apps" -UseBasicParsing -TimeoutSec 5
    if ($response.StatusCode -eq 200) {
        Write-Host "✓ API proxy working ($($response.StatusCode))" -ForegroundColor Green
    }
} catch {
    Write-Host "✗ API proxy failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n=== Setup Complete ===" -ForegroundColor Cyan
Write-Host "`nYour App Selector is now available at:" -ForegroundColor White
Write-Host "  http://localhost/" -ForegroundColor Cyan
Write-Host "`nAPI endpoints:" -ForegroundColor White
Write-Host "  http://localhost/api/apps" -ForegroundColor Cyan
Write-Host ""

# Show site status
Write-Host "Site Status:" -ForegroundColor White
Get-Website -Name $siteName | Format-Table Name, State, PhysicalPath, @{Name="Port";Expression={($_.bindings.Collection.bindingInformation -split ':')[1]}} -AutoSize
Write-Host ""

Read-Host "Press Enter to exit"
