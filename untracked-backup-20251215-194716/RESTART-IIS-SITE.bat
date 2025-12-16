@echo off
:: Restart IIS Site - Run as Administrator
echo Restarting IIS Site on port 8080...
powershell -ExecutionPolicy Bypass -Command "Start-Process PowerShell -Verb RunAs -ArgumentList '-ExecutionPolicy Bypass -File \"%~dp0RESTART-IIS-SITE.ps1\"'"
