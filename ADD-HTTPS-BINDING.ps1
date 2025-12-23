# ADD-HTTPS-BINDING.ps1
# Adds HTTPS binding with SSL certificate to IIS site
# Must be run as Administrator

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Add HTTPS Binding to IIS Site" -ForegroundColor Cyan
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

# Find certificate for domain
Write-Host "Searching for SSL certificate for $domainName..." -ForegroundColor Cyan
$cert = Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object { 
    $_.Subject -eq "CN=$domainName" -and $_.NotAfter -gt (Get-Date)
} | Sort-Object -Property NotAfter -Descending | Select-Object -First 1

if (-not $cert) {
    Write-Host ""
    Write-Host "ERROR: No valid SSL certificate found for $domainName" -ForegroundColor Red
    Write-Host ""
    Write-Host "Available certificates in LocalMachine\My:" -ForegroundColor Yellow
    Get-ChildItem -Path Cert:\LocalMachine\My | ForEach-Object {
        Write-Host "  - Subject: $($_.Subject)" -ForegroundColor Gray
        Write-Host "    Thumbprint: $($_.Thumbprint)" -ForegroundColor Gray
        Write-Host "    Expires: $($_.NotAfter)" -ForegroundColor Gray
        Write-Host ""
    }
    Write-Host "To create a self-signed certificate, run:" -ForegroundColor Yellow
    Write-Host "  CREATE-SELF-SIGNED-CERT.bat" -ForegroundColor Cyan
    Write-Host ""
    pause
    exit 1
}

Write-Host "✓ Found certificate:" -ForegroundColor Green
Write-Host "  Subject: $($cert.Subject)" -ForegroundColor White
Write-Host "  Thumbprint: $($cert.Thumbprint)" -ForegroundColor Yellow
Write-Host "  Issued: $($cert.NotBefore)" -ForegroundColor White
Write-Host "  Expires: $($cert.NotAfter)" -ForegroundColor White
Write-Host ""

# Ask which port for HTTPS
Write-Host "Which port should HTTPS use?" -ForegroundColor Cyan
Write-Host "  1. Port 443 (Standard HTTPS - Recommended)" -ForegroundColor White
Write-Host "     Access via: https://apps.tallman.com" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. Port 8443 (Alternative HTTPS)" -ForegroundColor White
Write-Host "     Access via: https://apps.tallman.com:8443" -ForegroundColor Gray
Write-Host ""

$choice = Read-Host "Enter choice (1 or 2)"

$port = 443
if ($choice -eq "2") {
    $port = 8443
}

Write-Host ""
Write-Host "Adding HTTPS binding on port $port..." -ForegroundColor Cyan

# Check if binding already exists
$existingBinding = Get-WebBinding -Name $siteName -Protocol "https" -Port $port -HostHeader $domainName -ErrorAction SilentlyContinue
if ($existingBinding) {
    Write-Host "⚠ HTTPS binding already exists on port $port" -ForegroundColor Yellow
    $overwrite = Read-Host "Remove and recreate? (y/n)"
    if ($overwrite -eq "y" -or $overwrite -eq "Y") {
        Remove-WebBinding -Name $siteName -Protocol "https" -Port $port -HostHeader $domainName
        Write-Host "✓ Removed existing binding" -ForegroundColor Green
    } else {
        Write-Host "Operation cancelled." -ForegroundColor Yellow
        pause
        exit 0
    }
}

try {
    # Create HTTPS binding with certificate
    New-WebBinding -Name $siteName -Protocol "https" -Port $port -HostHeader $domainName -SslFlags 1
    
    # Bind the certificate
    $binding = Get-WebBinding -Name $siteName -Protocol "https" -Port $port -HostHeader $domainName
    $binding.AddSslCertificate($cert.Thumbprint, "My")
    
    Write-Host "✓ HTTPS binding added successfully!" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "Updated site bindings:" -ForegroundColor Cyan
    Get-WebBinding -Name $siteName | ForEach-Object {
        $protocol = $_.protocol
        $bindingInfo = $_.bindingInformation
        if ($protocol -eq "https") {
            Write-Host "  - $protocol`://$bindingInfo" -ForegroundColor Green
        } else {
            Write-Host "  - $protocol`://$bindingInfo" -ForegroundColor Gray
        }
    }
    Write-Host ""
    
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "HTTPS Binding Added Successfully!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "Access URLs:" -ForegroundColor Cyan
    if ($port -eq 443) {
        Write-Host "  HTTPS: https://apps.tallman.com" -ForegroundColor Green
    } else {
        Write-Host "  HTTPS: https://apps.tallman.com:$port" -ForegroundColor Green
    }
    Write-Host ""
    
    Write-Host "IMPORTANT:" -ForegroundColor Yellow
    Write-Host "- Ensure DNS is configured (hosts file or DNS server)" -ForegroundColor White
    Write-Host "- If using self-signed cert, browser will show warning" -ForegroundColor White
    Write-Host "- Certificate is trusted on this machine only" -ForegroundColor White
    Write-Host "- For other machines, import: certs\apps.tallman.com.cer" -ForegroundColor White
    Write-Host ""
    
    Write-Host "HTTP to HTTPS Redirect:" -ForegroundColor Cyan
    Write-Host "To automatically redirect HTTP to HTTPS, the web.config" -ForegroundColor White
    Write-Host "file can be updated with redirect rules." -ForegroundColor White
    Write-Host ""
    
    Write-Host "Next Steps:" -ForegroundColor Cyan
    Write-Host "1. Ensure hosts file configured: ADD-HOSTS-ENTRY.bat" -ForegroundColor White
    Write-Host "2. Restart IIS: RESTART-IIS-SITE.bat" -ForegroundColor White
    Write-Host "3. Test HTTPS access: https://apps.tallman.com" -ForegroundColor White
    Write-Host ""
    
} catch {
    Write-Host ""
    Write-Host "ERROR: Failed to add HTTPS binding!" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    pause
    exit 1
}

pause
