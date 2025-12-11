@echo off
echo ========================================
echo FIX IIS SITE FOR APPSELECTOR
echo ========================================
echo.
echo This script will configure IIS to properly serve your AppSelector site.
echo.
pause

powershell -ExecutionPolicy Bypass -File "%~dp0fix-iis-site-admin.ps1"

echo.
echo ========================================
echo Script execution completed
echo ========================================
pause
