# Final IIS Fix - Grant Everyone Read to dist folder
# Run as Administrator

Write-Host "=== Final IIS Permissions Fix ===" -ForegroundColor Cyan

# Check if running as admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

$distPath = "C:\Users\BobM\TallmanApps\AppSelector\dist"

Write-Host "`nRemoving any restrictive permissions and granting Everyone Read..." -ForegroundColor Yellow

# Get current ACL
$acl = Get-Acl $distPath

# Disable inheritance and copy existing permissions
$acl.SetAccessRuleProtection($true, $true)

# Add Everyone with Read permissions
$everyoneRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
    "Everyone",
    "Read,ReadAndExecute,ListDirectory",
    "ContainerInherit,ObjectInherit",
    "None",
    "Allow"
)
$acl.AddAccessRule($everyoneRule)

# Add IUSR
$iusrRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
    "IUSR",
    "Read,ReadAndExecute,ListDirectory",
    "ContainerInherit,ObjectInherit",
    "None",
    "Allow"
)
$acl.AddAccessRule($iusrRule)

# Add IIS_IUSRS
$iisRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
    "IIS_IUSRS",
    "Read,ReadAndExecute,ListDirectory",
    "ContainerInherit,ObjectInherit",
    "None",
    "Allow"
)
$acl.AddAccessRule($iisRule)

# Apply the ACL
Set-Acl $distPath $acl

Write-Host "✓ Permissions set on dist folder" -ForegroundColor Green

# Now fix parent folders to allow traversal
Write-Host "`nFixing parent folder traverse permissions..." -ForegroundColor Yellow

$parentPaths = @(
    "C:\Users\BobM",
    "C:\Users\BobM\TallmanApps",
    "C:\Users\BobM\TallmanApps\AppSelector"
)

foreach ($path in $parentPaths) {
    Write-Host "  $path" -ForegroundColor White
    $acl = Get-Acl $path
    
    # Add traverse/execute for Everyone
    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
        "Everyone",
        "Traverse,ExecuteFile",
        "None",
        "None",
        "Allow"
    )
    $acl.AddAccessRule($rule)
    
    # Add for IUSR
    $rule2 = New-Object System.Security.AccessControl.FileSystemAccessRule(
        "IUSR",
        "Traverse,ExecuteFile",
        "None",
        "None",
        "Allow"
    )
    $acl.AddAccessRule($rule2)
    
    # Add for IIS_IUSRS
    $rule3 = New-Object System.Security.AccessControl.FileSystemAccessRule(
        "IIS_IUSRS",
        "Traverse,ExecuteFile",
        "None",
        "None",
        "Allow"
    )
    $acl.AddAccessRule($rule3)
    
    Set-Acl $path $acl
}

Write-Host "✓ Parent folder permissions set" -ForegroundColor Green

# Show final permissions
Write-Host "`nFinal permissions on dist folder:" -ForegroundColor Yellow
$acl = Get-Acl $distPath
$acl.Access | Where-Object { 
    $_.IdentityReference -eq "Everyone" -or
    $_.IdentityReference -eq "BUILTIN\IIS_IUSRS" -or
    $_.IdentityReference -eq "NT AUTHORITY\IUSR"
} | Format-Table IdentityReference, FileSystemRights, AccessControlType -AutoSize

Write-Host "`nRestarting IIS..." -ForegroundColor Yellow
iisreset /noforce
Write-Host "✓ IIS restarted" -ForegroundColor Green

Write-Host "`n=== Complete ===" -ForegroundColor Cyan
Write-Host "Permissions have been opened up. Test in IIS Manager now!" -ForegroundColor White
Write-Host ""
Read-Host "Press Enter to exit"
