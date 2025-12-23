@echo off
:: Batch file to run FINAL-FIX-AND-RESTART.ps1 as Administrator
echo Running Final Fix Script as Administrator...
powershell -ExecutionPolicy Bypass -Command "Start-Process PowerShell -Verb RunAs -ArgumentList '-ExecutionPolicy Bypass -File \"%~dp0FINAL-FIX-AND-RESTART.ps1\"'"
