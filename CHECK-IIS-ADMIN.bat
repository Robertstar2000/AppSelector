@echo off
:: Run check-iis-status.ps1 as Administrator
echo Checking IIS Configuration as Administrator...
powershell -ExecutionPolicy Bypass -Command "Start-Process PowerShell -Verb RunAs -ArgumentList '-ExecutionPolicy Bypass -File \"%~dp0check-iis-status.ps1\"'"
