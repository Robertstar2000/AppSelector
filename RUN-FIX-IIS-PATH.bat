@echo off
:: Fix IIS Physical Path - Run as Administrator
echo Fixing IIS Physical Path to point to dist folder...
powershell -ExecutionPolicy Bypass -Command "Start-Process PowerShell -Verb RunAs -ArgumentList '-ExecutionPolicy Bypass -File \"%~dp0FIX-IIS-PATH.ps1\"'"
