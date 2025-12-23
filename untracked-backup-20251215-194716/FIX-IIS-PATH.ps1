# Fix IIS Physical Path to point to dist folder
# MUST BE RUN AS ADMINISTRATOR

Write-Host "=== FIX IIS PHYSICAL PATH ===" -ForegroundColor Cyan
Write-Host ""

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Right-click and select 'Run as Administrator'" -ForegroundColor Yellow
    Write-Host ""
    pause
    exit 1
}

Write-Host "Running as Administrator" -ForegroundColor Green
Write-Host ""

try {
    Import-Module WebAdministration -ErrorAction Stop
    
    # Find site on port 8080
    $site = Get-Website | Where-Object { $_.Bindings.Collection.bindingInformation -like "*:8080:*" }
    
    if (-not $site) {
        Write-Host "ERROR: No IIS site found on port 8080!" -ForegroundColor Red
        Write-Host "You may need to create the site first." -ForegroundColor Yellow
        pause
        exit 1
    }
    
    Write-Host "Found site: $($site.Name)" -ForegroundColor Green
    Write-Host "Current physical path: $($site.PhysicalPath)" -ForegroundColor Yellow
    Write-Host ""
    
    # Check current path
    $correctPath = "C:\Users\BobM\TallmanApps\AppSelector\dist"
    $currentPath = $site.PhysicalPath
    
    if ($currentPath -eq $correctPath) {
        Write-Host "Physical path is already correct!" -ForegroundColor Green
        Write-Host ""
        Write-Host "The problem may be browser cache." -ForegroundColor Yellow
        Write-Host "Clear your browser cache (Ctrl+Shift+Delete) and reload." -ForegroundColor Yellow
    } else {
        Write-Host "PROBLEM FOUND!" -ForegroundColor Red
        Write-Host "IIS is pointing to: $currentPath" -ForegroundColor Red
        Write-Host "Should point to: $correctPath" -ForegroundColor Green
        Write-Host ""
        
        # Verify dist folder exists
        if (-not (Test-Path $correctPath)) {
            Write-Host "ERROR: dist folder does not exist!" -ForegroundColor Red
            Write-Host "Run: npm run build" -ForegroundColor Yellow
            pause
            exit 1
        }
        
        # Update the physical path
        Write-Host "Fixing physical path..." -ForegroundColor Yellow
        Set-ItemProperty "IIS:\Sites\$($site.Name)" -Name physicalPath -Value $correctPath
        
        Write-Host "Physical path updated!" -ForegroundColor Green
        Write-Host ""
        
        # Restart the site
        Write-Host "Restarting IIS site..." -ForegroundColor Yellow
        Stop-Website -Name $site.Name
        Start-Sleep -Seconds 2
        Start-Website -Name $site.Name
        
        Write-Host "Site restarted!" -ForegroundColor Green
    }
    
    Write-Host ""
    Write-Host "=== NEXT STEPS ===" -ForegroundColor Cyan
    Write-Host "1. Clear your browser cache (Ctrl+Shift+Delete)" -ForegroundColor White
    Write-Host "2. Navigate to http://localhost:8080" -ForegroundColor White
    Write-Host "3. Press Ctrl+F5 (hard refresh)" -ForegroundColor White
    Write-Host ""
    Write-Host "The application should now load correctly!" -ForegroundColor Green
    
} catch {
    Write-Host "ERROR: $_" -ForegroundColor Red
}

Write-Host ""
pause
