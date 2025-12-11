# CREATE-SELF-SIGNED-CERT.ps1
# Creates a self-signed SSL certificate for apps.tallman.com
# Must be run as Administrator

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Create Self-Signed SSL Certificate" -ForegroundColor Cyan
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

$domainName = "apps.tallman.com"
$friendlyName = "AppSelector SSL Certificate"

Write-Host "This script will create a self-signed SSL certificate for:" -ForegroundColor White
Write-Host "  Domain: $domainName" -ForegroundColor Yellow
Write-Host ""
Write-Host "Note: Self-signed certificates are for DEVELOPMENT/TESTING only!" -ForegroundColor Yellow
Write-Host "Browsers will show security warnings." -ForegroundColor Yellow
Write-Host "For PRODUCTION, obtain a certificate from a trusted CA." -ForegroundColor Yellow
Write-Host ""

$continue = Read-Host "Continue? (y/n)"
if ($continue -ne "y" -and $continue -ne "Y") {
    Write-Host "Operation cancelled." -ForegroundColor Yellow
    pause
    exit 0
}

Write-Host ""
Write-Host "Creating self-signed certificate..." -ForegroundColor Cyan

try {
    # Check if certificate already exists
    $existingCert = Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object { $_.Subject -eq "CN=$domainName" }
    if ($existingCert) {
        Write-Host ""
        Write-Host "⚠ Certificate already exists:" -ForegroundColor Yellow
        Write-Host "  Subject: $($existingCert.Subject)" -ForegroundColor Gray
        Write-Host "  Thumbprint: $($existingCert.Thumbprint)" -ForegroundColor Gray
        Write-Host "  Expires: $($existingCert.NotAfter)" -ForegroundColor Gray
        Write-Host ""
        $overwrite = Read-Host "Create new certificate anyway? (y/n)"
        if ($overwrite -ne "y" -and $overwrite -ne "Y") {
            Write-Host ""
            Write-Host "Using existing certificate." -ForegroundColor Green
            Write-Host "Thumbprint: $($existingCert.Thumbprint)" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "To use this certificate, run: ADD-HTTPS-BINDING.bat" -ForegroundColor Cyan
            pause
            exit 0
        }
    }

    # Create self-signed certificate
    $cert = New-SelfSignedCertificate `
        -DnsName $domainName `
        -CertStoreLocation "Cert:\LocalMachine\My" `
        -FriendlyName $friendlyName `
        -NotAfter (Get-Date).AddYears(5) `
        -KeyExportPolicy Exportable `
        -KeySpec KeyExchange `
        -KeyLength 2048 `
        -KeyAlgorithm RSA `
        -HashAlgorithm SHA256

    Write-Host "✓ Certificate created successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Certificate Details:" -ForegroundColor Cyan
    Write-Host "  Subject: $($cert.Subject)" -ForegroundColor White
    Write-Host "  Thumbprint: $($cert.Thumbprint)" -ForegroundColor Yellow
    Write-Host "  Issued: $($cert.NotBefore)" -ForegroundColor White
    Write-Host "  Expires: $($cert.NotAfter)" -ForegroundColor White
    Write-Host "  Store Location: LocalMachine\My" -ForegroundColor White
    Write-Host ""

    # Export certificate to file (for importing to other machines/browsers)
    $certPath = "C:\Users\BobM\TallmanApps\AppSelector\certs"
    if (-not (Test-Path $certPath)) {
        New-Item -Path $certPath -ItemType Directory -Force | Out-Null
    }

    $certFile = Join-Path $certPath "apps.tallman.com.cer"
    Export-Certificate -Cert $cert -FilePath $certFile -Force | Out-Null
    Write-Host "✓ Certificate exported to: $certFile" -ForegroundColor Green
    Write-Host ""

    # Add to Trusted Root (to avoid browser warnings on this machine)
    Write-Host "Adding certificate to Trusted Root Certification Authorities..." -ForegroundColor Cyan
    $store = New-Object System.Security.Cryptography.X509Certificates.X509Store("Root", "LocalMachine")
    $store.Open("ReadWrite")
    $store.Add($cert)
    $store.Close()
    Write-Host "✓ Certificate added to Trusted Root" -ForegroundColor Green
    Write-Host ""

    Write-Host "========================================" -ForegroundColor Green
    Write-Host "Certificate Created Successfully!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""

    Write-Host "Next Steps:" -ForegroundColor Cyan
    Write-Host "1. Run ADD-HTTPS-BINDING.bat to bind this certificate to IIS" -ForegroundColor White
    Write-Host "2. The site will be accessible via https://apps.tallman.com" -ForegroundColor White
    Write-Host ""
    Write-Host "Certificate Thumbprint (save this):" -ForegroundColor Yellow
    Write-Host $cert.Thumbprint -ForegroundColor Yellow
    Write-Host ""

    Write-Host "For Other Machines:" -ForegroundColor Cyan
    Write-Host "To avoid browser warnings on other computers, import:" -ForegroundColor White
    Write-Host "  $certFile" -ForegroundColor Gray
    Write-Host "Into: Trusted Root Certification Authorities" -ForegroundColor Gray
    Write-Host ""

    Write-Host "WARNING: Self-Signed Certificates" -ForegroundColor Yellow
    Write-Host "-------------------------------------" -ForegroundColor Yellow
    Write-Host "- Only for development/testing" -ForegroundColor Gray
    Write-Host "- Browsers will show warnings (unless cert is trusted)" -ForegroundColor Gray
    Write-Host "- NOT suitable for production internet sites" -ForegroundColor Gray
    Write-Host "- For production, get certificate from Let's Encrypt or commercial CA" -ForegroundColor Gray
    Write-Host ""

} catch {
    Write-Host ""
    Write-Host "ERROR: Failed to create certificate!" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    pause
    exit 1
}

pause
