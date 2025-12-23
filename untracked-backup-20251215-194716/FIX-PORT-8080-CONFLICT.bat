@echo off
:: Fix Port 8080 Conflict - Kill Node.js and Start IIS
echo Fixing port 8080 conflict (killing Node.js, starting IIS)...
powershell -ExecutionPolicy Bypass -Command "Start-Process PowerShell -Verb RunAs -ArgumentList '-ExecutionPolicy Bypass -File \"%~dp0FIX-PORT-8080-CONFLICT.ps1\"'"
