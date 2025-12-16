# Fix IIS Permissions for TallmanApps folder
# Run as Administrator

Write-Host "=== Fixing IIS Permissions ===" -ForegroundColor Cyan

# Check if running as admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

$folderPath = "C:\Users\BobM\TallmanApps"
$appPoolIdentity = "IIS AppPool\WEB03"

Write-Host "`nGranting IIS permissions to $folderPath..." -ForegroundColor Yellow

# Grant permissions to IIS_IUSRS
Write-Host "  Adding permissions for IIS_IUSRS..." -ForegroundColor White
$acl = Get-Acl $folderPath
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("IIS_IUSRS","ReadAndExecute, ListDirectory","ContainerInherit,ObjectInherit","None","Allow")
$acl.SetAccessRule($accessRule)
Set-Acl $folderPath $acl

# Grant permissions to the specific App Pool identity
Write-Host "  Adding permissions for App Pool: WEB03..." -ForegroundColor White
try {
    $acl = Get-Acl $folderPath
    $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($appPoolIdentity,"ReadAndExecute, ListDirectory","ContainerInherit,ObjectInherit","None","Allow")
    $acl.SetAccessRule($accessRule)
    Set-Acl $folderPath $acl
    Write-Host "  ✓ App Pool permissions granted" -ForegroundColor Green
} catch {
    Write-Host "  Note: Could not add App Pool identity (this is okay)" -ForegroundColor Gray
}

# Grant permissions to IUSR
Write-Host "  Adding permissions for IUSR..." -ForegroundColor White
$acl = Get-Acl $folderPath
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("IUSR","ReadAndExecute, ListDirectory","ContainerInherit,ObjectInherit","None","Allow")
$acl.SetAccessRule($accessRule)
Set-Acl $folderPath $acl

Write-Host "✓ Permissions granted!" -ForegroundColor Green

# Show current permissions
Write-Host "`nCurrent permissions on $folderPath" ":" -ForegroundColor White
$acl = Get-Acl $folderPath
$acl.Access | Where-Object { $_.IdentityReference -like "*IIS*" -or $_.IdentityReference -like "*IUSR*" } | Format-Table IdentityReference, FileSystemRights, AccessControlType -AutoSize

Write-Host "`nRecommendation:" -ForegroundColor Yellow
Write-Host "  Since you want to host multiple apps, use:" -ForegroundColor White
Write-Host "    C:\Users\BobM\TallmanApps" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Then access AppSelector at:" -ForegroundColor White
Write-Host "    http://localhost/AppSelector/dist/" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Or if you only want AppSelector, use:" -ForegroundColor White
Write-Host "    C:\Users\BobM\TallmanApps\AppSelector\dist" -ForegroundColor Cyan
Write-Host "  Then access at:" -ForegroundColor White
Write-Host "    http://localhost/" -ForegroundColor Cyan
Write-Host ""

Read-Host "Press Enter to exit"
