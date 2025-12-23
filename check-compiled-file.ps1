# Check what's in the compiled JavaScript file
$jsFile = "dist\assets\index-Dufiu7Og.js"

if (Test-Path $jsFile) {
    $content = Get-Content $jsFile -Raw
    $fileSize = (Get-Item $jsFile).Length
    
    Write-Host "File: $jsFile"
    Write-Host "Size: $fileSize bytes"
    Write-Host ""
    
    # Check for React Router references
    $foundUseNavigate = $content -match "useNavigate"
    $foundAppContext = $content -match "AppContext"
    $foundAppProvider = $content -match "AppProvider"
    $foundReactRouter = $content -match "react-router"
    
    Write-Host "=== Search Results ==="
    Write-Host "useNavigate found: $foundUseNavigate"
    Write-Host "AppContext found: $foundAppContext"
    Write-Host "AppProvider found: $foundAppProvider"
    Write-Host "react-router found: $foundReactRouter"
    Write-Host ""
    
    # Show first 1000 characters
    Write-Host "=== First 1000 characters ==="
    Write-Host $content.Substring(0, [Math]::Min(1000, $content.Length))
    
} else {
    Write-Host "File not found: $jsFile"
}
