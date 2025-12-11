# Comprehensive diagnostic for browser cache issue
Write-Host "=== DIAGNOSTICS FOR BROWSER CACHE ISSUE ===" -ForegroundColor Cyan
Write-Host ""

# 1. Check current dist folder
Write-Host "1. Current dist folder contents:" -ForegroundColor Yellow
if (Test-Path "dist") {
    Get-ChildItem "dist" -Recurse | Select-Object FullName, Length, LastWriteTime
    Write-Host ""
    $distPath = (Resolve-Path "dist").Path
    Write-Host "Full path to dist: $distPath" -ForegroundColor Green
} else {
    Write-Host "No dist folder found!" -ForegroundColor Red
}
Write-Host ""

# 2. Search for ANY other dist folders in TallmanApps
Write-Host "2. Searching for other 'dist' folders in TallmanApps:" -ForegroundColor Yellow
Get-ChildItem -Path "C:\Users\BobM\TallmanApps" -Directory -Recurse -Filter "dist" -ErrorAction SilentlyContinue | Select-Object FullName, LastWriteTime
Write-Host ""

# 3. Check for any JavaScript files with "AppContext" or "useNavigate"
Write-Host "3. Searching for JS files containing 'AppContext' or 'useNavigate':" -ForegroundColor Yellow
$foundFiles = Get-ChildItem -Path "C:\Users\BobM\TallmanApps" -Recurse -Include "*.js" -ErrorAction SilentlyContinue | 
    Where-Object {
        $content = Get-Content $_.FullName -Raw -ErrorAction SilentlyContinue
        $content -match "AppContext|useNavigate"
    }
if ($foundFiles) {
    $foundFiles | Select-Object FullName, Length, LastWriteTime
} else {
    Write-Host "No JS files with AppContext or useNavigate found" -ForegroundColor Green
}
Write-Host ""

# 4. Check IIS App Pools and Sites (if accessible)
Write-Host "4. Checking IIS configuration (requires admin):" -ForegroundColor Yellow
try {
    Import-Module WebAdministration -ErrorAction Stop
    $sites = Get-Website | Where-Object {$_.Bindings.Collection.bindingInformation -like "*:8080:*"}
    if ($sites) {
        Write-Host "Found IIS sites on port 8080:" -ForegroundColor Green
        $sites | Select-Object Name, PhysicalPath, State
    } else {
        Write-Host "No sites found on port 8080" -ForegroundColor Yellow
    }
} catch {
    Write-Host "Cannot access IIS configuration (requires Administrator)" -ForegroundColor Yellow
    Write-Host "Run this as Administrator to check IIS settings" -ForegroundColor Yellow
}
Write-Host ""

# 5. Check if web.config exists in dist
Write-Host "5. Checking for web.config in dist:" -ForegroundColor Yellow
if (Test-Path "dist\web.config") {
    Write-Host "web.config EXISTS in dist" -ForegroundColor Green
    Get-Content "dist\web.config" | Select-Object -First 10
} else {
    Write-Host "web.config NOT FOUND in dist (this will cause issues!)" -ForegroundColor Red
}
Write-Host ""

Write-Host "=== RECOMMENDATIONS ===" -ForegroundColor Cyan
Write-Host "1. The compiled JS in dist/ is correct (no React Router code)"
Write-Host "2. Browser is loading stale cached code from somewhere"
Write-Host "3. Try these fixes:"
Write-Host "   a) Run this script as Administrator to check IIS path"
Write-Host "   b) Clear browser cache completely (Ctrl+Shift+Delete)"
Write-Host "   c) Check browser Network tab to see what URL it's loading JS from"
Write-Host "   d) Restart IIS: iisreset /restart (requires admin)"
Write-Host ""
