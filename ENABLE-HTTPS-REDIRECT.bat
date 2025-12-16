@echo off
REM ENABLE-HTTPS-REDIRECT.bat
REM Enables automatic redirect from HTTP to HTTPS in web.config
REM This batch file ensures the PowerShell script runs properly

echo ========================================
echo Enable HTTP to HTTPS Redirect
echo ========================================
echo.

echo Running PowerShell script...
echo.

powershell -ExecutionPolicy Bypass -File "%~dp0ENABLE-HTTPS-REDIRECT.ps1"

if %errorLevel% neq 0 (
    echo.
    echo ERROR: Script execution failed!
    pause
    exit /b 1
)

echo.
echo Script completed successfully!
pause
