# Port Recommendations for AppSelector

## The Copilot "Issue"

**Important:** Copilot isn't hijacking port 8080 - it's your **browser extension** redirecting the URL in the browser itself. The server is working correctly (confirmed by testing).

Port numbers don't prevent this - changing ports won't fix the extension redirect. The real fix is disabling the extension or using incognito mode.

---

## Best Port Options (No Firewall Changes Needed)

### Option 1: Port 80 (Best - Standard HTTP) ✅ RECOMMENDED

**Advantages:**
- Standard HTTP port (like websites)
- No firewall issues (already open)
- Clean URL: `http://localhost` (no port number needed!)
- Professional and standard

**Command to change:**
```powershell
powershell -ExecutionPolicy Bypass -File CHANGE-IIS-PORT.ps1 -NewPort 80
```

**Access with:**
```
http://localhost
```

**Note:** Port 80 might be used by Default Web Site in IIS. If so, stop that site first.

### Option 2: Port 8081, 8082, 8083 (Alternative to 8080)

**Advantages:**
- Close to 8080 (easy to remember)
- Usually not conflicted with other apps
- No firewall changes needed

**Command to change:**
```powershell
powershell -ExecutionPolicy Bypass -File CHANGE-IIS-PORT.ps1 -NewPort 8081
```

**Access with:**
```
http://localhost:8081
```

### Option 3: Port 5000 (Common Development Port)

**Advantages:**
- Commonly used for web development
- Usually available
- No firewall issues

**Command to change:**
```powershell
powershell -ExecutionPolicy Bypass -File CHANGE-IIS-PORT.ps1 -NewPort 5000
```

**Access with:**
```
http://localhost:5000
```

---

## Ports That Need Firewall Changes (Not Recommended)

These require firewall rules and are more complex:
- Ports 1-1023 (except 80): System/privileged ports
- Ports above 49152: Dynamic/private range
- Custom non-standard ports

---

## How to Change Port

### Step 1: Run the Change Script

**As Administrator**, run:
```powershell
powershell -ExecutionPolicy Bypass -File CHANGE-IIS-PORT.ps1 -NewPort <YOUR_CHOICE>
```

Examples:
```powershell
# Change to port 80 (recommended)
powershell -ExecutionPolicy Bypass -File CHANGE-IIS-PORT.ps1 -NewPort 80

# Change to port 8081
powershell -ExecutionPolicy Bypass -File CHANGE-IIS-PORT.ps1 -NewPort 8081

# Change to port 5000
powershell -ExecutionPolicy Bypass -File CHANGE-IIS-PORT.ps1 -NewPort 5000
```

### Step 2: Update START-PRODUCTION.ps1

After changing the port, you need to update the startup script to reference the new port.

The script currently checks for port 8080. Update it to check for your new port.

---

## Port Conflicts

If you get "port already in use" error:

### Find what's using the port:
```powershell
netstat -ano | findstr ":<PORT_NUMBER>"
```

### Check IIS sites:
```powershell
powershell -Command "Import-Module WebAdministration; Get-Website | Select-Object Name, @{Name='Port';Expression={$_.Bindings.Collection.bindingInformation}}"
```

### Stop conflicting IIS site:
```powershell
powershell -Command "Import-Module WebAdministration; Stop-Website -Name '<SITE_NAME>'"
```

---

## Solving the Copilot Extension Issue

**The real problem** isn't the port - it's the browser extension. Here are fixes:

### Fix 1: Use Incognito Mode (Quickest)
- Press `Ctrl + Shift + N`
- Extensions are disabled by default
- Works immediately

### Fix 2: Disable Copilot Extension
1. Browser menu → Extensions
2. Find Microsoft Copilot or AI assistant extensions
3. Disable or remove
4. Reload `http://localhost`

### Fix 3: Use Different Browser
- Chrome without extensions
- Firefox
- Edge without Copilot

### Fix 4: Configure Extension
Some extensions let you whitelist/blacklist URLs:
1. Open extension settings
2. Add localhost to exclusion list
3. Reload page

---

## My Recommendation

**For Production:**

1. **Change to Port 80** for clean URLs:
   ```powershell
   powershell -ExecutionPolicy Bypass -File CHANGE-IIS-PORT.ps1 -NewPort 80
   ```
   Access: `http://localhost`

2. **Fix browser extension** (one time):
   - Disable Copilot extension, OR
   - Use different browser for localhost

3. **Benefits:**
   - Professional standard port
   - No port number in URL
   - No firewall changes
   - Clean and simple

**If port 80 is unavailable, use 8081 as second choice.**

---

## Testing After Port Change

1. Run: `START-PRODUCTION.bat` (may need to update for new port)
2. Check services:
   ```powershell
   netstat -ano | findstr ":<YOUR_PORT>"
   netstat -ano | findstr ":3001"
   ```
3. Access: `http://localhost:<YOUR_PORT>`
4. Use incognito if needed

---

## Summary

- ✅ **Best:** Port 80 (`http://localhost`)
- ✅ **Alternative:** 8081, 8082, 5000
- ❌ **The Copilot issue:** Browser extension, not port number
- 🔧 **Real fix:** Disable extension or use incognito mode
- 📝 **Script:** `CHANGE-IIS-PORT.ps1 -NewPort <NUMBER>`

**Changing the port won't fix the Copilot redirect** - that's a browser extension issue. But port 80 is still recommended for cleaner URLs!
