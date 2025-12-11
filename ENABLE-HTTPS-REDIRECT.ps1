# ENABLE-HTTPS-REDIRECT.ps1
# Enables automatic redirect from HTTP to HTTPS in web.config
# Run this after setting up HTTPS binding

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Enable HTTP to HTTPS Redirect" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$webConfigPath = "C:\Users\BobM\TallmanApps\AppSelector\public\web.config"

if (-not (Test-Path $webConfigPath)) {
    Write-Host "ERROR: web.config not found at: $webConfigPath" -ForegroundColor Red
    pause
    exit 1
}

Write-Host "This script will add HTTP to HTTPS redirect rules to web.config" -ForegroundColor White
Write-Host ""
Write-Host "Location: $webConfigPath" -ForegroundColor Gray
Write-Host ""

# Create backup
$backupPath = $webConfigPath + ".backup-https-" + (Get-Date -Format "yyyyMMdd-HHmmss")
Copy-Item $webConfigPath $backupPath
Write-Host "✓ Backup created: $backupPath" -ForegroundColor Green
Write-Host ""

# Read current web.config
$webConfig = [xml](Get-Content $webConfigPath)

# Check if redirect rule already exists
$existingRule = $webConfig.configuration.'system.webServer'.rewrite.rules.rule | Where-Object { $_.name -eq "Redirect to HTTPS" }

if ($existingRule) {
    Write-Host "⚠ HTTPS redirect rule already exists in web.config" -ForegroundColor Yellow
    Write-Host ""
    $overwrite = Read-Host "Recreate redirect rule? (y/n)"
    if ($overwrite -ne "y" -and $overwrite -ne "Y") {
        Write-Host "Operation cancelled." -ForegroundColor Yellow
        pause
        exit 0
    }
    # Remove existing rule
    $webConfig.configuration.'system.webServer'.rewrite.rules.RemoveChild($existingRule) | Out-Null
    Write-Host "✓ Removed existing redirect rule" -ForegroundColor Green
}

Write-Host ""
Write-Host "Adding HTTPS redirect rule..." -ForegroundColor Cyan

# Ensure rewrite section exists
if (-not $webConfig.configuration.'system.webServer'.rewrite) {
    $rewrite = $webConfig.CreateElement("rewrite")
    $webConfig.configuration.'system.webServer'.AppendChild($rewrite) | Out-Null
}

if (-not $webConfig.configuration.'system.webServer'.rewrite.rules) {
    $rules = $webConfig.CreateElement("rules")
    $webConfig.configuration.'system.webServer'.rewrite.AppendChild($rules) | Out-Null
}

# Create HTTPS redirect rule
$rule = $webConfig.CreateElement("rule")
$rule.SetAttribute("name", "Redirect to HTTPS")
$rule.SetAttribute("stopProcessing", "true")

# Match condition (HTTP requests)
$match = $webConfig.CreateElement("match")
$match.SetAttribute("url", "(.*)")
$rule.AppendChild($match) | Out-Null

# Conditions (only redirect HTTP, not HTTPS)
$conditions = $webConfig.CreateElement("conditions")
$condition = $webConfig.CreateElement("add")
$condition.SetAttribute("input", "{HTTPS}")
$condition.SetAttribute("pattern", "^OFF$")
$conditions.AppendChild($condition) | Out-Null
$rule.AppendChild($conditions) | Out-Null

# Action (redirect to HTTPS)
$action = $webConfig.CreateElement("action")
$action.SetAttribute("type", "Redirect")
$action.SetAttribute("url", "https://{HTTP_HOST}/{R:1}")
$action.SetAttribute("redirectType", "Permanent")
$rule.AppendChild($action) | Out-Null

# Add rule to rules collection
$webConfig.configuration.'system.webServer'.rewrite.rules.AppendChild($rule) | Out-Null

# Save web.config
$webConfig.Save($webConfigPath)

Write-Host "✓ HTTPS redirect rule added successfully!" -ForegroundColor Green
Write-Host ""

# Also update dist/web.config if it exists
$distWebConfigPath = "C:\Users\BobM\TallmanApps\AppSelector\dist\web.config"
if (Test-Path $distWebConfigPath) {
    Write-Host "Updating dist/web.config..." -ForegroundColor Cyan
    Copy-Item $webConfigPath $distWebConfigPath -Force
    Write-Host "✓ dist/web.config updated" -ForegroundColor Green
    Write-Host ""
}

Write-Host "========================================" -ForegroundColor Green
Write-Host "HTTPS Redirect Enabled!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

Write-Host "What This Does:" -ForegroundColor Cyan
Write-Host "- All HTTP requests will automatically redirect to HTTPS" -ForegroundColor White
Write-Host "- Example: http://apps.tallman.com → https://apps.tallman.com" -ForegroundColor Gray
Write-Host "- Permanent redirect (301 status code)" -ForegroundColor Gray
Write-Host ""

Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "1. Rebuild if needed: npm run build" -ForegroundColor White
Write-Host "2. Restart IIS: RESTART-IIS-SITE.bat" -ForegroundColor White
Write-Host "3. Test HTTP access (should redirect): http://apps.tallman.com" -ForegroundColor White
Write-Host "4. Verify HTTPS works: https://apps.tallman.com" -ForegroundColor White
Write-Host ""

Write-Host "To Disable:" -ForegroundColor Yellow
Write-Host "Restore from backup: $backupPath" -ForegroundColor Gray
Write-Host ""

pause
