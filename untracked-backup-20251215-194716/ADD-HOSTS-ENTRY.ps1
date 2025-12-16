# ADD-HOSTS-ENTRY.ps1
# Adds apps.tallman.com to Windows hosts file for local testing
# Must be run as Administrator

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Add Domain to Windows Hosts File" -ForegroundColor Cyan
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

$hostsPath = "C:\Windows\System32\drivers\etc\hosts"
$domainName = "apps.tallman.com"

Write-Host "This script will add '$domainName' to your hosts file." -ForegroundColor White
Write-Host "Hosts file location: $hostsPath" -ForegroundColor Gray
Write-Host ""

# Check current hosts file content
Write-Host "Checking current hosts file..." -ForegroundColor Cyan
$hostsContent = Get-Content $hostsPath -ErrorAction Stop

# Check if entry already exists
$existingEntry = $hostsContent | Where-Object { $_ -match $domainName -and $_ -notmatch "^\s*#" }
if ($existingEntry) {
    Write-Host "✓ Domain already exists in hosts file:" -ForegroundColor Yellow
    Write-Host "  $existingEntry" -ForegroundColor Gray
    Write-Host ""
    $continue = Read-Host "Do you want to continue anyway? (y/n)"
    if ($continue -ne "y" -and $continue -ne "Y") {
        Write-Host "Operation cancelled." -ForegroundColor Yellow
        pause
        exit 0
    }
}

Write-Host ""
Write-Host "Which IP address should the domain point to?" -ForegroundColor Cyan
Write-Host "  1. 127.0.0.1 (localhost - for local testing on this machine)" -ForegroundColor White
Write-Host "  2. Enter custom IP address (for network testing)" -ForegroundColor White
Write-Host ""

$choice = Read-Host "Enter choice (1 or 2)"

$ipAddress = "127.0.0.1"

if ($choice -eq "2") {
    $customIP = Read-Host "Enter IP address"
    # Basic IP validation
    if ($customIP -match "^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$") {
        $ipAddress = $customIP
    } else {
        Write-Host "Invalid IP address. Using 127.0.0.1 instead." -ForegroundColor Yellow
        $ipAddress = "127.0.0.1"
    }
}

Write-Host ""
Write-Host "Adding entry: $ipAddress    $domainName" -ForegroundColor Cyan

# Create backup
$backupPath = "$hostsPath.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
Copy-Item $hostsPath $backupPath -Force
Write-Host "✓ Backup created: $backupPath" -ForegroundColor Green

# Add entry to hosts file
$newEntry = "$ipAddress    $domainName"
Add-Content -Path $hostsPath -Value ""
Add-Content -Path $hostsPath -Value "# Added by AppSelector setup - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Add-Content -Path $hostsPath -Value $newEntry

Write-Host "✓ Entry added to hosts file" -ForegroundColor Green
Write-Host ""

# Flush DNS cache
Write-Host "Flushing DNS cache..." -ForegroundColor Cyan
ipconfig /flushdns | Out-Null
Write-Host "✓ DNS cache flushed" -ForegroundColor Green
Write-Host ""

# Test DNS resolution
Write-Host "Testing DNS resolution..." -ForegroundColor Cyan
$dnsResult = Resolve-DnsName -Name $domainName -ErrorAction SilentlyContinue
if ($dnsResult) {
    Write-Host "✓ DNS resolves to: $($dnsResult.IPAddress)" -ForegroundColor Green
} else {
    Write-Host "⚠ Could not resolve DNS (this is normal if using hosts file)" -ForegroundColor Yellow
}

# Test ping
Write-Host ""
Write-Host "Testing connectivity..." -ForegroundColor Cyan
$pingResult = Test-Connection -ComputerName $domainName -Count 1 -ErrorAction SilentlyContinue
if ($pingResult) {
    Write-Host "✓ Ping successful to: $($pingResult.IPV4Address)" -ForegroundColor Green
} else {
    Write-Host "⚠ Ping failed (firewall may be blocking)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Hosts Entry Added Successfully!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "1. Run ADD-DOMAIN-BINDING.bat to add IIS binding" -ForegroundColor White
Write-Host "2. Restart IIS: .\RESTART-IIS-SITE.bat" -ForegroundColor White
Write-Host "3. Test access: http://apps.tallman.com" -ForegroundColor White
Write-Host ""

Write-Host "To remove this entry later:" -ForegroundColor Yellow
Write-Host "1. Edit: $hostsPath" -ForegroundColor Gray
Write-Host "2. Delete the line containing: $domainName" -ForegroundColor Gray
Write-Host "3. Run: ipconfig /flushdns" -ForegroundColor Gray
Write-Host ""

pause
