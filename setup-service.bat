@echo off
echo Installing NSSM service...
C:\nssm\nssm-2.24\win64\nssm.exe install AppSelectorBackend "C:\Program Files\nodejs\node.exe" "c:\Users\BobM\TallmanApps\AppSelector\backend\server.cjs"

echo Setting working directory...
C:\nssm\nssm-2.24\win64\nssm.exe set AppSelectorBackend AppDirectory "c:\Users\BobM\TallmanApps\AppSelector"

echo Setting display name and description...
C:\nssm\nssm-2.24\win64\nssm.exe set AppSelectorBackend DisplayName "App Selector Backend"
C:\nssm\nssm-2.24\win64\nssm.exe set AppSelectorBackend Description "Backend service for the App Selector application"

echo Setting startup type to automatic...
C:\nssm\nssm-2.24\win64\nssm.exe set AppSelectorBackend Start SERVICE_AUTO_START

echo Starting service...
timeout /t 2 /nobreak > nul
sc.exe start AppSelectorBackend

echo Service setup complete!
pause
