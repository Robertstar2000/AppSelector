# ADD-DOMAIN-BINDING.ps1
# Adds apps.tallman.com domain binding to IIS site
# Must be run as Administrator

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Adding Domain Binding to IIS Site" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if running as administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    pause
    exit 1
}

Import-Module WebAdministration -ErrorAction Stop

$siteName = "AppSelector"
$domainName = "apps.tallman.com"

Write-Host "Site Name: $siteName" -ForegroundColor White
Write-Host "Domain: $domainName" -ForegroundColor White
Write-Host ""

# Check if site exists
$site = Get-WebSite -Name $siteName -ErrorAction SilentlyContinue
if (-not $site) {
    Write-Host "ERROR: Site '$siteName' not found!" -ForegroundColor Red
    Write-Host "Please run setup-iis-site.ps1 first to create the site." -ForegroundColor Yellow
    pause
    exit 1
}

Write-Host "Current site bindings:" -ForegroundColor Yellow
Get-WebBinding -Name $siteName | ForEach-Object {
    Write-Host "  - $($_.protocol)://$($_.bindingInformation)" -ForegroundColor Gray
}
Write-Host ""

# Ask which port to bind to
Write-Host "Which port should the domain use?" -ForegroundColor Cyan
Write-Host "  1. Port 80 (Standard HTTP - Recommended for production)" -ForegroundColor White
Write-Host "     Access via: http://apps.tallman.com" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. Port 8080 (Alternative HTTP)" -ForegroundColor White
Write-Host "     Access via: http://apps.tallman.com:8080" -ForegroundColor Gray
Write-Host ""
Write-Host "  3. Both ports" -ForegroundColor White
Write-Host ""

$choice = Read-Host "Enter choice (1, 2, or 3)"

$port80 = $false
$port8080 = $false

switch ($choice) {
    "1" { $port80 = $true }
    "2" { $port8080 = $true }
    "3" { $port80 = $true; $port8080 = $true }
    default {
        Write-Host "Invalid choice. Defaulting to port 80." -ForegroundColor Yellow
        $port80 = $true
    }
}

Write-Host ""
Write-Host "Adding domain bindings..." -ForegroundColor Cyan

# Add port 80 binding
if ($port80) {
    $binding80 = Get-WebBinding -Name $siteName -Protocol "http" -Port 80 -HostHeader $domainName -ErrorAction SilentlyContinue
    if ($binding80) {
        Write-Host "  Port 80 binding already exists for $domainName" -ForegroundColor Yellow
    } else {
        New-WebBinding -Name $siteName -Protocol "http" -Port 80 -HostHeader $domainName
        Write-Host "  ✓ Added binding: http://${domainName}:80" -ForegroundColor Green
    }
}

# Add port 8080 binding
if ($port8080) {
    $binding8080 = Get-WebBinding -Name $siteName -Protocol "http" -Port 8080 -HostHeader $domainName -ErrorAction SilentlyContinue
    if ($binding8080) {
        Write-Host "  Port 8080 binding already exists for $domainName" -ForegroundColor Yellow
    } else {
        New-WebBinding -Name $siteName -Protocol "http" -Port 8080 -HostHeader $domainName
        Write-Host "  ✓ Added binding: http://${domainName}:8080" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "Updated site bindings:" -ForegroundColor Cyan
Get-WebBinding -Name $siteName | ForEach-Object {
    Write-Host "  - $($_.protocol)://$($_.bindingInformation)" -ForegroundColor Green
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Domain Binding Added Successfully!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

Write-Host "IMPORTANT - DNS Configuration:" -ForegroundColor Yellow
Write-Host "-------------------------------" -ForegroundColor Yellow
Write-Host "For the domain to work, you must ensure DNS is configured:" -ForegroundColor White
Write-Host ""
Write-Host "1. Add an A record for 'apps.tallman.com' pointing to:" -ForegroundColor White
Write-Host "   - This server's IP address if accessing from other machines" -ForegroundColor Gray
Write-Host "   - 127.0.0.1 if testing locally on this machine" -ForegroundColor Gray
Write-Host ""
Write-Host "2. If this is a local test, add to Windows hosts file:" -ForegroundColor White
Write-Host "   File: C:\Windows\System32\drivers\etc\hosts" -ForegroundColor Gray
Write-Host "   Add line: 127.0.0.1    apps.tallman.com" -ForegroundColor Gray
Write-Host ""

Write-Host "Testing DNS resolution..." -ForegroundColor Cyan
$dnsResult = Resolve-DnsName -Name $domainName -ErrorAction SilentlyContinue
if ($dnsResult) {
    Write-Host "✓ DNS resolves to: $($dnsResult.IPAddress)" -ForegroundColor Green
} else {
    Write-Host "⚠ DNS does not resolve yet. Configure DNS or hosts file first." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "1. Ensure DNS is configured (see above)" -ForegroundColor White
Write-Host "2. Restart IIS: .\RESTART-IIS-SITE.ps1" -ForegroundColor White
Write-Host "3. Test access:" -ForegroundColor White
if ($port80) {
    Write-Host "   http://apps.tallman.com" -ForegroundColor Gray
}
if ($port8080) {
    Write-Host "   http://apps.tallman.com:8080" -ForegroundColor Gray
}
Write-Host ""

pause
