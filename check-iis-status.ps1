# Check IIS Status and Configuration
# Run as Administrator to see full details

Write-Host "=== IIS STATUS CHECK ===" -ForegroundColor Cyan
Write-Host ""

# Check if running as admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if ($isAdmin) {
    Write-Host "Running as Administrator" -ForegroundColor Green
} else {
    Write-Host "NOT running as Administrator - limited information available" -ForegroundColor Yellow
}
Write-Host ""

# Check if port 8080 is in use
Write-Host "1. Checking if port 8080 is in use..." -ForegroundColor Yellow
$port8080 = netstat -ano | findstr ":8080"
if ($port8080) {
    Write-Host "Port 8080 is in use" -ForegroundColor Green
    Write-Host $port8080
} else {
    Write-Host "Port 8080 is NOT in use - IIS may not be running!" -ForegroundColor Red
}
Write-Host ""

# Check IIS service status
Write-Host "2. Checking IIS service status..." -ForegroundColor Yellow
try {
    $w3svc = Get-Service -Name W3SVC -ErrorAction Stop
    Write-Host "IIS service status: $($w3svc.Status)" -ForegroundColor Cyan
} catch {
    Write-Host "IIS service not found or error: $_" -ForegroundColor Red
}
Write-Host ""

# Check dist folder
Write-Host "3. Checking dist folder..." -ForegroundColor Yellow
$distPath = "C:\Users\BobM\TallmanApps\AppSelector\dist"
if (Test-Path $distPath) {
    Write-Host "dist folder exists: $distPath" -ForegroundColor Green
    
    if (Test-Path "$distPath\index.html") {
        Write-Host "  index.html found" -ForegroundColor Green
    } else {
        Write-Host "  index.html NOT found" -ForegroundColor Red
    }
    
    if (Test-Path "$distPath\web.config") {
        Write-Host "  web.config found" -ForegroundColor Green
    } else {
        Write-Host "  web.config NOT found" -ForegroundColor Red
    }
    
    $jsFiles = Get-ChildItem "$distPath\assets\*.js" -ErrorAction SilentlyContinue
    if ($jsFiles) {
        Write-Host "  JavaScript files: $($jsFiles.Count)" -ForegroundColor Green
    }
} else {
    Write-Host "dist folder NOT found!" -ForegroundColor Red
    Write-Host "Run: npm run build" -ForegroundColor Yellow
}
Write-Host ""

# Check IIS sites (requires admin)
Write-Host "4. Checking IIS sites..." -ForegroundColor Yellow
if ($isAdmin) {
    try {
        Import-Module WebAdministration -ErrorAction Stop
        $allSites = Get-Website
        
        Write-Host "All IIS Sites:" -ForegroundColor Cyan
        foreach ($site in $allSites) {
            $binding = $site.Bindings.Collection.bindingInformation
            $siteName = $site.Name
            $sitePath = $site.PhysicalPath
            $siteState = $site.State
            Write-Host "  Site: $siteName" -ForegroundColor White
            Write-Host "    Binding: $binding" -ForegroundColor Gray
            Write-Host "    Path: $sitePath" -ForegroundColor Gray
            Write-Host "    State: $siteState" -ForegroundColor Gray
        }
        Write-Host ""
        
        # Check specifically for port 8080
        $site8080 = $allSites | Where-Object { $_.Bindings.Collection.bindingInformation -like "*:8080:*" }
        if ($site8080) {
            Write-Host "Found site on port 8080:" -ForegroundColor Green
            Write-Host "  Name: $($site8080.Name)" -ForegroundColor Cyan
            Write-Host "  Path: $($site8080.PhysicalPath)" -ForegroundColor Cyan
            Write-Host "  State: $($site8080.State)" -ForegroundColor Cyan
        } else {
            Write-Host "No site found on port 8080!" -ForegroundColor Red
        }
    } catch {
        Write-Host "Error accessing IIS: $_" -ForegroundColor Red
    }
} else {
    Write-Host "Run as Administrator to see IIS site details" -ForegroundColor Yellow
}
Write-Host ""

Write-Host "=== RECOMMENDATIONS ===" -ForegroundColor Cyan
if (-not $port8080) {
    Write-Host "Port 8080 is not active!" -ForegroundColor Red
    Write-Host "Action: Run RUN-AS-ADMIN-FINAL-FIX.bat" -ForegroundColor Yellow
}
Write-Host ""
pause
