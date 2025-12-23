# Change IIS Port from 8080 to Port 80 (Standard HTTP)
# Run as Administrator

param(
    [int]$NewPort = 80
)

Write-Host "=== CHANGE IIS PORT ===" -ForegroundColor Cyan
Write-Host ""

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "ERROR: Must run as Administrator!" -ForegroundColor Red
    pause
    exit 1
}

Write-Host "Changing IIS port to: $NewPort" -ForegroundColor Yellow
Write-Host ""

try {
    Import-Module WebAdministration -ErrorAction Stop
    
    # Find AppSelector site
    $site = Get-Website | Where-Object { $_.Name -like "*AppSelector*" }
    
    if (-not $site) {
        Write-Host "ERROR: AppSelector site not found!" -ForegroundColor Red
        Write-Host "Available sites:" -ForegroundColor Yellow
        Get-Website | Select-Object Name
        pause
        exit 1
    }
    
    Write-Host "Found site: $($site.Name)" -ForegroundColor Green
    $oldBinding = $site.Bindings.Collection.bindingInformation
    Write-Host "Current binding: $oldBinding" -ForegroundColor Yellow
    Write-Host ""
    
    # Check if new port is already in use
    $portPattern = "*:$NewPort" + ":*"
    $existingSite = Get-Website | Where-Object { $_.Bindings.Collection.bindingInformation -like $portPattern }
    if ($existingSite -and $existingSite.Name -ne $site.Name) {
        Write-Host "ERROR: Port $NewPort is already used by: $($existingSite.Name)" -ForegroundColor Red
        Write-Host "Choose a different port or stop that site first" -ForegroundColor Yellow
        pause
        exit 1
    }
    
    # Stop the site
    Write-Host "Stopping site..." -ForegroundColor Yellow
    Stop-Website -Name $site.Name -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    
    # Remove old binding
    Write-Host "Removing old binding..." -ForegroundColor Yellow
    $binding = Get-WebBinding -Name $site.Name
    Remove-WebBinding -Name $site.Name -BindingInformation $binding.bindingInformation
    
    # Add new binding
    Write-Host "Adding new binding on port $NewPort..." -ForegroundColor Yellow
    New-WebBinding -Name $site.Name -Protocol "http" -Port $NewPort -IPAddress "*"
    
    # Start the site
    Write-Host "Starting site..." -ForegroundColor Yellow
    Start-Website -Name $site.Name
    Start-Sleep -Seconds 2
    
    $newState = (Get-Website -Name $site.Name).State
    $newBinding = (Get-Website -Name $site.Name).Bindings.Collection.bindingInformation
    
    Write-Host ""
    Write-Host "SUCCESS!" -ForegroundColor Green
    Write-Host "  Site: $($site.Name)" -ForegroundColor Cyan
    Write-Host "  State: $newState" -ForegroundColor Cyan
    Write-Host "  New Binding: $newBinding" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Access your app at: http://localhost:$NewPort" -ForegroundColor Green
    Write-Host ""
    
    if ($NewPort -eq 80) {
        Write-Host "Port 80 is the standard HTTP port!" -ForegroundColor Green
        Write-Host "You can now access the app at: http://localhost" -ForegroundColor Cyan
        Write-Host "(No need to specify :80 in the URL)" -ForegroundColor Gray
    }
    
} catch {
    Write-Host "ERROR: $_" -ForegroundColor Red
}

Write-Host ""
pause
