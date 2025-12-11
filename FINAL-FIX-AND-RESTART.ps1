# FINAL FIX: Restart IIS and clear all caches
# This script must be run as Administrator

Write-Host "=== FINAL FIX: Clearing Caches and Restarting IIS ===" -ForegroundColor Cyan
Write-Host ""

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Right-click this script and select 'Run as Administrator'" -ForegroundColor Yellow
    Write-Host ""
    pause
    exit 1
}

Write-Host "✓ Running as Administrator" -ForegroundColor Green
Write-Host ""

# Step 1: Stop IIS
Write-Host "Step 1: Stopping IIS..." -ForegroundColor Yellow
try {
    iisreset /stop
    Write-Host "✓ IIS stopped" -ForegroundColor Green
} catch {
    Write-Host "Warning: Error stopping IIS: $_" -ForegroundColor Yellow
}
Write-Host ""

# Step 2: Clear IIS cache and temporary files
Write-Host "Step 2: Clearing IIS cache..." -ForegroundColor Yellow
$tempPath = "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\Temporary ASP.NET Files"

if (Test-Path $tempPath) {
    Remove-Item -Path "$tempPath\*" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "✓ Cleared ASP.NET temporary files" -ForegroundColor Green
} else {
    Write-Host "✓ No ASP.NET temporary files to clear" -ForegroundColor Green
}
Write-Host ""

# Step 3: Verify dist folder has correct files
Write-Host "Step 3: Verifying dist folder..." -ForegroundColor Yellow
$distPath = "C:\Users\BobM\TallmanApps\AppSelector\dist"
if (Test-Path $distPath) {
    Write-Host "✓ dist folder exists at: $distPath" -ForegroundColor Green
    
    if (Test-Path "$distPath\web.config") {
        Write-Host "✓ web.config exists in dist" -ForegroundColor Green
    } else {
        Write-Host "✗ web.config MISSING! Run 'npm run build' first!" -ForegroundColor Red
    }
    
    if (Test-Path "$distPath\index.html") {
        Write-Host "✓ index.html exists in dist" -ForegroundColor Green
    }
    
    $jsFiles = Get-ChildItem "$distPath\assets\*.js" -ErrorAction SilentlyContinue
    if ($jsFiles) {
        Write-Host "✓ JavaScript files found: $($jsFiles.Count)" -ForegroundColor Green
    }
} else {
    Write-Host "✗ dist folder not found! Run 'npm run build' first!" -ForegroundColor Red
}
Write-Host ""

# Step 4: Check IIS site configuration
Write-Host "Step 4: Checking IIS site configuration..." -ForegroundColor Yellow
try {
    Import-Module WebAdministration
    $site = Get-Website | Where-Object {$_.Bindings.Collection.bindingInformation -like "*:8080:*"}
    
    if ($site) {
        Write-Host "✓ Found site: $($site.Name)" -ForegroundColor Green
        Write-Host "  Physical Path: $($site.PhysicalPath)" -ForegroundColor Cyan
        Write-Host "  State: $($site.State)" -ForegroundColor Cyan
        
        # Check if physical path matches our dist folder
        if ($site.PhysicalPath -like "*AppSelector\dist*") {
            Write-Host "✓ IIS is pointing to correct AppSelector\dist folder" -ForegroundColor Green
        } else {
            Write-Host "⚠ WARNING: IIS physical path doesn't match AppSelector\dist!" -ForegroundColor Yellow
            Write-Host "  Expected something like: C:\Users\BobM\TallmanApps\AppSelector\dist" -ForegroundColor Yellow
            Write-Host "  Actual: $($site.PhysicalPath)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "⚠ No IIS site found on port 8080" -ForegroundColor Yellow
    }
} catch {
    Write-Host "✗ Error checking IIS: $_" -ForegroundColor Red
}
Write-Host ""

# Step 5: Start IIS
Write-Host "Step 5: Starting IIS..." -ForegroundColor Yellow
try {
    iisreset /start
    Write-Host "✓ IIS started" -ForegroundColor Green
} catch {
    Write-Host "✗ Error starting IIS: $_" -ForegroundColor Red
}
Write-Host ""

# Final instructions
Write-Host "=== NEXT STEPS ===" -ForegroundColor Cyan
Write-Host "1. ✓ IIS has been restarted" -ForegroundColor Green
Write-Host "2. Open your browser and do the following:" -ForegroundColor Yellow
Write-Host "   a) Press Ctrl+Shift+Delete" -ForegroundColor White
Write-Host "   b) Select 'All time' or 'Everything'" -ForegroundColor White
Write-Host "   c) Check 'Cached images and files'" -ForegroundColor White
Write-Host "   d) Click 'Clear data'" -ForegroundColor White
Write-Host "3. Navigate to http://localhost:8080" -ForegroundColor Yellow
Write-Host "4. Press Ctrl+F5 (hard refresh)" -ForegroundColor Yellow
Write-Host ""
Write-Host "If you still see errors, open Developer Tools (F12) and check:" -ForegroundColor Cyan
Write-Host "- Network tab: What URL is the JS being loaded from?" -ForegroundColor White
Write-Host "- Console tab: What is the exact error message?" -ForegroundColor White
Write-Host ""
pause
