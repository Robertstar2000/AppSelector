@echo off
:: Start Production Environment - IIS + Backend Service
echo Starting Production Environment...
powershell -ExecutionPolicy Bypass -Command "Start-Process PowerShell -Verb RunAs -ArgumentList '-ExecutionPolicy Bypass -File \"%~dp0START-PRODUCTION.ps1\"'"
