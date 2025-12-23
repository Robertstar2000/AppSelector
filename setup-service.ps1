# Create the NSSM service
C:\nssm\nssm-2.24\win64\nssm.exe install AppSelectorBackend "C:\Program Files\nodejs\node.exe" "c:\Users\BobM\TallmanApps\AppSelector\backend\server.cjs"

# Set the working directory
C:\nssm\nssm-2.24\win64\nssm.exe set AppSelectorBackend AppDirectory "c:\Users\BobM\TallmanApps\AppSelector"

# Set display name and description
C:\nssm\nssm-2.24\win64\nssm.exe set AppSelectorBackend DisplayName "App Selector Backend"
C:\nssm\nssm-2.24\win64\nssm.exe set AppSelectorBackend Description "Backend service for the App Selector application"

# Configure startup type (auto)
C:\nssm\nssm-2.24\win64\nssm.exe set AppSelectorBackend Start SERVICE_AUTO_START

# Start the service
sc.exe start AppSelectorBackend
