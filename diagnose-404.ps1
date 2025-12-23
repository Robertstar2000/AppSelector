# Diagnose 404 Error - Check IIS Configuration

Write-Host "`n=== IIS SITE CONFIGURATION DIAGNOSIS ===" -ForegroundColor Cyan

# Check if running as admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "`nWARNING: Not running as Administrator. Some checks may fail." -ForegroundColor Yellow
    Write-Host "Run this script as Administrator for full diagnostics.`n" -ForegroundColor Yellow
}

# Try to import WebAdministration module
try {
    Import-Module WebAdministration -ErrorAction Stop
    Write-Host "[OK] WebAdministration module loaded" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Cannot load WebAdministration module (need admin)" -ForegroundColor Red
    Write-Host "Trying alternative method..." -ForegroundColor Yellow
}

# Method 1: Try WebAdministration cmdlets
Write-Host "`n1. Checking IIS Sites..." -ForegroundColor Yellow
try {
    $sites = Get-Website -ErrorAction Stop
    Write-Host "`nFound IIS Sites:" -ForegroundColor Green
    foreach ($site in $sites) {
        Write-Host "`n  Site Name: $($site.Name)" -ForegroundColor Cyan
        Write-Host "  Physical Path: $($site.PhysicalPath)" -ForegroundColor White
        Write-Host "  State: $($site.State)" -ForegroundColor White
        Write-Host "  Bindings: $($site.Bindings.Collection.bindingInformation)" -ForegroundColor White
        
        # Check if this is our site
        if ($site.PhysicalPath -like "*AppSelector*") {
            Write-Host "  >>> THIS IS THE APPSELECTOR SITE <<<" -ForegroundColor Green
            
            # Check if physical path exists
            if (Test-Path $site.PhysicalPath) {
                Write-Host "  [OK] Physical path exists" -ForegroundColor Green
                
                # List contents
                Write-Host "`n  Contents of physical path:" -ForegroundColor Yellow
                Get-ChildItem $site.PhysicalPath | ForEach-Object {
                    Write-Host "    - $($_.Name)" -ForegroundColor Gray
                }
            } else {
                Write-Host "  [ERROR] Physical path DOES NOT EXIST!" -ForegroundColor Red
            }
        }
    }
    
    # Check Application Pools
    Write-Host "`n2. Checking Application Pools..." -ForegroundColor Yellow
    $appPools = Get-ChildItem IIS:\AppPools -ErrorAction Stop
    foreach ($pool in $appPools) {
        if ($pool.Name -like "*AppSelector*") {
            Write-Host "`n  Pool Name: $($pool.Name)" -ForegroundColor Cyan
            Write-Host "  State: $($pool.State)" -ForegroundColor White
            Write-Host "  .NET CLR Version: $($pool.managedRuntimeVersion)" -ForegroundColor White
            Write-Host "  Pipeline Mode: $($pool.managedPipelineMode)" -ForegroundColor White
            Write-Host "  Identity: $($pool.processModel.identityType)" -ForegroundColor White
        }
    }
    
} catch {
    Write-Host "[ERROR] Cannot query IIS: $($_.Exception.Message)" -ForegroundColor Red
}

# Method 2: Try appcmd.exe
Write-Host "`n3. Trying appcmd.exe method..." -ForegroundColor Yellow
try {
    $appcmdPath = "$env:SystemRoot\System32\inetsrv\appcmd.exe"
    if (Test-Path $appcmdPath) {
        Write-Host "[OK] appcmd.exe found" -ForegroundColor Green
        
        Write-Host "`nListing all IIS sites:" -ForegroundColor Yellow
        & $appcmdPath list site
        
        Write-Host "`nListing all IIS apps:" -ForegroundColor Yellow
        & $appcmdPath list app
        
    } else {
        Write-Host "[ERROR] appcmd.exe not found" -ForegroundColor Red
    }
} catch {
    Write-Host "[ERROR] Cannot run appcmd.exe: $($_.Exception.Message)" -ForegroundColor Red
}

# Check Event Viewer for recent IIS errors
Write-Host "`n4. Checking Recent IIS Errors in Event Log..." -ForegroundColor Yellow
try {
    $recentErrors = Get-EventLog -LogName System -Source "Microsoft-Windows-IIS*" -EntryType Error -Newest 5 -ErrorAction SilentlyContinue
    if ($recentErrors) {
        Write-Host "Recent IIS Errors:" -ForegroundColor Red
        foreach ($evt in $recentErrors) {
            Write-Host "  Time: $($evt.TimeGenerated)" -ForegroundColor Gray
            Write-Host "  Message: $($evt.Message)" -ForegroundColor White
        }
    } else {
        Write-Host "[OK] No recent IIS errors found" -ForegroundColor Green
    }
} catch {
    Write-Host "Could not query Event Log" -ForegroundColor Yellow
}

# Summary and recommendations
Write-Host "`n=== RECOMMENDATIONS ===" -ForegroundColor Cyan
Write-Host "1. Ensure IIS site physical path points to: C:\Users\BobM\TallmanApps\AppSelector\dist" -ForegroundColor White
Write-Host "2. Ensure the IIS site is Started" -ForegroundColor White
Write-Host "3. Check the URL you're using matches the site bindings" -ForegroundColor White
Write-Host "4. Verify index.html exists in the dist folder" -ForegroundColor White
Write-Host "5. Check IIS logs for more details: C:\inetpub\logs\LogFiles\" -ForegroundColor White

Write-Host "`n=== TO FIX ===" -ForegroundColor Cyan
Write-Host "Run this command as Administrator to update the site physical path:" -ForegroundColor Yellow
Write-Host 'Set-ItemProperty "IIS:\Sites\<YourSiteName>" -Name physicalPath -Value "C:\Users\BobM\TallmanApps\AppSelector\dist"' -ForegroundColor White
