# Restart IIS Site on Port 8080
# Run as Administrator

Write-Host "=== RESTARTING IIS SITE ===" -ForegroundColor Cyan
Write-Host ""

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "ERROR: Must run as Administrator!" -ForegroundColor Red
    pause
    exit 1
}

try {
    Import-Module WebAdministration -ErrorAction Stop
    
    # Find and restart site on port 8080
    $site = Get-Website | Where-Object { $_.Bindings.Collection.bindingInformation -like "*:8080:*" }
    
    if ($site) {
        Write-Host "Found site: $($site.Name)" -ForegroundColor Green
        Write-Host "Current state: $($site.State)" -ForegroundColor Yellow
        Write-Host ""
        
        Write-Host "Stopping site..." -ForegroundColor Yellow
        Stop-Website -Name $site.Name -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
        
        Write-Host "Starting site..." -ForegroundColor Yellow
        Start-Website -Name $site.Name
        Start-Sleep -Seconds 2
        
        $newState = (Get-Website -Name $site.Name).State
        Write-Host "New state: $newState" -ForegroundColor Green
        
        if ($newState -eq "Started") {
            Write-Host "" 
            Write-Host "SUCCESS! Site is now running." -ForegroundColor Green
            Write-Host "Try accessing http://localhost:8080 now" -ForegroundColor Cyan
        } else {
            Write-Host ""
            Write-Host "WARNING: Site may not have started correctly" -ForegroundColor Yellow
        }
    } else {
        Write-Host "ERROR: No site found on port 8080" -ForegroundColor Red
    }
    
} catch {
    Write-Host "ERROR: $_" -ForegroundColor Red
}

Write-Host ""
pause
