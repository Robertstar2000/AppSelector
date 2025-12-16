# Test what's actually on port 8080
Write-Host "Testing port 8080..." -ForegroundColor Cyan
Write-Host ""

try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080" -UseBasicParsing -TimeoutSec 10
    
    Write-Host "Status Code: $($response.StatusCode)" -ForegroundColor Green
    Write-Host ""
    
    # Get title
    if ($response.Content -match '<title>(.*?)</title>') {
        Write-Host "Page Title: $($matches[1])" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "First 1000 characters of response:" -ForegroundColor Cyan
    Write-Host $response.Content.Substring(0, [Math]::Min(1000, $response.Content.Length))
    
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
pause
