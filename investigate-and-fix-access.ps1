# Investigation and Fix Script for AppSelector Access Issues
# This script will diagnose and fix IIS access issues

Write-Host "`n=== INVESTIGATION REPORT ===" -ForegroundColor Cyan

# 1. Check if directories exist
Write-Host "`n1. Checking Directory Existence..." -ForegroundColor Yellow
$appSelectorPath = "C:\Users\BobM\TallmanApps\AppSelector"
$distPath = "C:\Users\BobM\TallmanApps\AppSelector\dist"

if (Test-Path $appSelectorPath) {
    Write-Host "   [OK] AppSelector directory exists" -ForegroundColor Green
} else {
    Write-Host "   [ERROR] AppSelector directory NOT FOUND" -ForegroundColor Red
}

if (Test-Path $distPath) {
    Write-Host "   [OK] dist directory exists" -ForegroundColor Green
} else {
    Write-Host "   [ERROR] dist directory NOT FOUND" -ForegroundColor Red
}

# 2. Check current permissions
Write-Host "`n2. Current Permissions on AppSelector:" -ForegroundColor Yellow
$aclApp = Get-Acl $appSelectorPath
$aclApp.Access | Format-Table IdentityReference, FileSystemRights, AccessControlType -AutoSize

Write-Host "`n   Current Permissions on dist:" -ForegroundColor Yellow
$aclDist = Get-Acl $distPath
$aclDist.Access | Format-Table IdentityReference, FileSystemRights, AccessControlType -AutoSize

# 3. Check if IIS users have access
Write-Host "`n3. Checking IIS User Access..." -ForegroundColor Yellow
$iisUsers = @("IIS_IUSRS", "IUSR", "IIS APPPOOL\AppSelector")
$hasIISAccess = $false

foreach ($user in $iisUsers) {
    $hasAccessApp = $aclApp.Access | Where-Object { $_.IdentityReference -like "*$user*" }
    $hasAccessDist = $aclDist.Access | Where-Object { $_.IdentityReference -like "*$user*" }
    
    if ($hasAccessApp -or $hasAccessDist) {
        Write-Host "   [OK] Found $user with access" -ForegroundColor Green
        $hasIISAccess = $true
    } else {
        Write-Host "   [MISSING] $user does NOT have access" -ForegroundColor Red
    }
}

# 4. Check IIS configuration (if possible)
Write-Host "`n4. Checking IIS Configuration..." -ForegroundColor Yellow
try {
    $iisApps = Get-WmiObject -Namespace "root\WebAdministration" -Class Site -ErrorAction SilentlyContinue
    if ($iisApps) {
        Write-Host "   IIS Sites found:" -ForegroundColor Green
        $iisApps | ForEach-Object {
            Write-Host "   - $($_.Name)" -ForegroundColor Gray
        }
    } else {
        Write-Host "   Could not query IIS sites directly" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   Could not query IIS (may need admin privileges)" -ForegroundColor Yellow
}

# 5. Check for web.config in dist
Write-Host "`n5. Checking for web.config..." -ForegroundColor Yellow
$webConfigPath = "$distPath\web.config"
if (Test-Path $webConfigPath) {
    Write-Host "   [OK] web.config exists in dist folder" -ForegroundColor Green
} else {
    Write-Host "   [MISSING] web.config NOT FOUND in dist folder" -ForegroundColor Red
}

# 6. DIAGNOSIS
Write-Host "`n=== DIAGNOSIS ===" -ForegroundColor Cyan
if (-not $hasIISAccess) {
    Write-Host "   PROBLEM FOUND: IIS users (IIS_IUSRS, IUSR) do not have permissions!" -ForegroundColor Red
    Write-Host "   This is why you cannot access the site through IIS/browser." -ForegroundColor Red
}

# 7. APPLY FIX
Write-Host "`n=== APPLYING FIX ===" -ForegroundColor Cyan
Write-Host "Adding IIS user permissions to allow web access..." -ForegroundColor Yellow

try {
    # Add IIS_IUSRS permissions to AppSelector folder
    Write-Host "`nAdding IIS_IUSRS to AppSelector folder..." -ForegroundColor Yellow
    $acl1 = Get-Acl $appSelectorPath
    $permission1 = "IIS_IUSRS","Read,ReadAndExecute","ContainerInherit,ObjectInherit","None","Allow"
    $accessRule1 = New-Object System.Security.AccessControl.FileSystemAccessRule $permission1
    $acl1.SetAccessRule($accessRule1)
    Set-Acl $appSelectorPath $acl1
    Write-Host "   [OK] Added IIS_IUSRS to AppSelector" -ForegroundColor Green

    # Add IUSR permissions to AppSelector folder
    Write-Host "`nAdding IUSR to AppSelector folder..." -ForegroundColor Yellow
    $acl2 = Get-Acl $appSelectorPath
    $permission2 = "IUSR","Read,ReadAndExecute","ContainerInherit,ObjectInherit","None","Allow"
    $accessRule2 = New-Object System.Security.AccessControl.FileSystemAccessRule $permission2
    $acl2.SetAccessRule($accessRule2)
    Set-Acl $appSelectorPath $acl2
    Write-Host "   [OK] Added IUSR to AppSelector" -ForegroundColor Green

    # Add IIS_IUSRS permissions to dist folder
    Write-Host "`nAdding IIS_IUSRS to dist folder..." -ForegroundColor Yellow
    $acl3 = Get-Acl $distPath
    $permission3 = "IIS_IUSRS","Read,ReadAndExecute","ContainerInherit,ObjectInherit","None","Allow"
    $accessRule3 = New-Object System.Security.AccessControl.FileSystemAccessRule $permission3
    $acl3.SetAccessRule($accessRule3)
    Set-Acl $distPath $acl3
    Write-Host "   [OK] Added IIS_IUSRS to dist" -ForegroundColor Green

    # Add IUSR permissions to dist folder
    Write-Host "`nAdding IUSR to dist folder..." -ForegroundColor Yellow
    $acl4 = Get-Acl $distPath
    $permission4 = "IUSR","Read,ReadAndExecute","ContainerInherit,ObjectInherit","None","Allow"
    $accessRule4 = New-Object System.Security.AccessControl.FileSystemAccessRule $permission4
    $acl4.SetAccessRule($accessRule4)
    Set-Acl $distPath $acl4
    Write-Host "   [OK] Added IUSR to dist" -ForegroundColor Green

    Write-Host "`n=== FIX COMPLETE ===" -ForegroundColor Green
    Write-Host "IIS users now have read permissions to access the directories." -ForegroundColor Green
    
} catch {
    Write-Host "`n   [ERROR] $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "   You may need to run this script as Administrator" -ForegroundColor Yellow
}

# 8. VERIFY FIX
Write-Host "`n=== VERIFICATION ===" -ForegroundColor Cyan
Write-Host "New permissions on AppSelector:" -ForegroundColor Yellow
$aclVerify1 = Get-Acl $appSelectorPath
$aclVerify1.Access | Format-Table IdentityReference, FileSystemRights, AccessControlType -AutoSize

Write-Host "New permissions on dist:" -ForegroundColor Yellow
$aclVerify2 = Get-Acl $distPath
$aclVerify2.Access | Format-Table IdentityReference, FileSystemRights, AccessControlType -AutoSize

Write-Host "`n=== NEXT STEPS ===" -ForegroundColor Cyan
Write-Host "1. Try accessing your site through browser" -ForegroundColor White
Write-Host "2. If still having issues, check IIS Application Pool identity" -ForegroundColor White
Write-Host "3. Ensure IIS site is pointing to the correct physical path" -ForegroundColor White
Write-Host "4. Check Event Viewer for detailed IIS errors" -ForegroundColor White
