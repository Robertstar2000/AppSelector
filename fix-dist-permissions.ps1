# Fix Permissions for dist folder
# Run as Administrator

Write-Host "=== Fixing Permissions for dist Folder ===" -ForegroundColor Cyan

# Check if running as admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

$distPath = "C:\Users\BobM\TallmanApps\AppSelector\dist"

Write-Host "`nGranting IIS permissions to $distPath..." -ForegroundColor Yellow

# Grant permissions to IIS_IUSRS
Write-Host "  Adding IIS_IUSRS..." -ForegroundColor White
$acl = Get-Acl $distPath
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("IIS_IUSRS","Read,ReadAndExecute,ListDirectory","ContainerInherit,ObjectInherit","None","Allow")
$acl.SetAccessRule($accessRule)
Set-Acl $distPath $acl

# Grant permissions to IUSR
Write-Host "  Adding IUSR..." -ForegroundColor White
$acl = Get-Acl $distPath
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("IUSR","Read,ReadAndExecute,ListDirectory","ContainerInherit,ObjectInherit","None","Allow")
$acl.SetAccessRule($accessRule)
Set-Acl $distPath $acl

# Grant permissions to DefaultAppPool identity
Write-Host "  Adding DefaultAppPool..." -ForegroundColor White
try {
    $acl = Get-Acl $distPath
    $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("IIS AppPool\DefaultAppPool","Read,ReadAndExecute,ListDirectory","ContainerInherit,ObjectInherit","None","Allow")
    $acl.SetAccessRule($accessRule)
    Set-Acl $distPath $acl
    Write-Host "  ✓ DefaultAppPool permissions set" -ForegroundColor Green
} catch {
    Write-Host "  Note: DefaultAppPool identity not added" -ForegroundColor Gray
}

Write-Host "✓ Permissions granted to dist folder!" -ForegroundColor Green

# Restart IIS
Write-Host "`nRestarting IIS..." -ForegroundColor Yellow
iisreset /noforce
Write-Host "✓ IIS restarted" -ForegroundColor Green

Write-Host "`n=== Complete ===" -ForegroundColor Cyan
Write-Host "Now close the IIS Manager dialogs and click 'Browse' to test!" -ForegroundColor White
Write-Host ""
Read-Host "Press Enter to exit"
