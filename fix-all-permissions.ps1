# Fix ALL Permissions for IIS to access dist folder
# Run as Administrator

Write-Host "=== Comprehensive IIS Permissions Fix ===" -ForegroundColor Cyan

# Check if running as admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Paths to fix
$paths = @(
    "C:\Users\BobM",
    "C:\Users\BobM\TallmanApps",
    "C:\Users\BobM\TallmanApps\AppSelector",
    "C:\Users\BobM\TallmanApps\AppSelector\dist"
)

# Identities to grant
$identities = @("IIS_IUSRS", "IUSR", "IIS AppPool\DefaultAppPool", "IIS AppPool\TallmanApps")

Write-Host "`nGranting permissions to all paths..." -ForegroundColor Yellow

foreach ($path in $paths) {
    Write-Host "`nPath: $path" -ForegroundColor White
    
    foreach ($identity in $identities) {
        try {
            $acl = Get-Acl $path
            
            # For the final dist folder, grant full Read access
            if ($path -like "*\dist") {
                $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
                    $identity,
                    "Read,ReadAndExecute,ListDirectory",
                    "ContainerInherit,ObjectInherit",
                    "None",
                    "Allow"
                )
            } else {
                # For parent folders, just Read+Execute (traverse)
                $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
                    $identity,
                    "ReadAndExecute,ListDirectory",
                    "None",
                    "None",
                    "Allow"
                )
            }
            
            $acl.AddAccessRule($accessRule)
            Set-Acl $path $acl
            Write-Host "  ✓ $identity" -ForegroundColor Green
        } catch {
            Write-Host "  - $identity (skipped)" -ForegroundColor Gray
        }
    }
}

Write-Host "`n✓ All permissions granted!" -ForegroundColor Green

# Show final permissions on dist folder
Write-Host "`nFinal permissions on dist folder:" -ForegroundColor White
$distPath = "C:\Users\BobM\TallmanApps\AppSelector\dist"
$acl = Get-Acl $distPath
$acl.Access | Where-Object { 
    $_.IdentityReference -like "*IIS*" -or 
    $_.IdentityReference -like "*IUSR*" -or
    $_.IdentityReference -like "*DefaultAppPool*" -or
    $_.IdentityReference -like "*TallmanApps*"
} | Format-Table IdentityReference, FileSystemRights, AccessControlType -AutoSize

Write-Host "`nRestarting IIS..." -ForegroundColor Yellow
iisreset /noforce
Write-Host "✓ IIS restarted" -ForegroundColor Green

Write-Host "`n=== Complete ===" -ForegroundColor Cyan
Write-Host "Go back to IIS Manager and click 'Test Settings...' again!" -ForegroundColor White
Write-Host ""
Read-Host "Press Enter to exit"
