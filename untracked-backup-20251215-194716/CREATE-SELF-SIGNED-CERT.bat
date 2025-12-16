@echo off
REM CREATE-SELF-SIGNED-CERT.bat
REM Creates a self-signed SSL certificate for apps.tallman.com
REM This batch file ensures the PowerShell script runs with admin privileges

echo ========================================
echo Create Self-Signed SSL Certificate
echo ========================================
echo.

REM Check for admin privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: This script must be run as Administrator!
    echo Right-click this file and select "Run as administrator"
    pause
    exit /b 1
)

echo Running PowerShell script...
echo.

powershell -ExecutionPolicy Bypass -File "%~dp0CREATE-SELF-SIGNED-CERT.ps1"

if %errorLevel% neq 0 (
    echo.
    echo ERROR: Script execution failed!
    pause
    exit /b 1
)

echo.
echo Script completed successfully!
pause
