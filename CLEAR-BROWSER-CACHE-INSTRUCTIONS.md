# Complete Browser Cache Clearing Instructions

## The Problem
IIS is serving the CORRECT file with title "Tallman Application Selector", but your browser is showing "Dashboard" from cache!

This means your browser has **aggressively cached** an old version or different application.

## Solutions (Try in order)

### Solution 1: Nuclear Option - Clear EVERYTHING
1. **Close ALL browser windows completely**
2. Press `Ctrl + Shift + Delete` (in browser)
3. Select **"All time"** or **"Everything"**
4. Check EVERY box:
   - ✅ Browsing history
   - ✅ Cookies and other site data
   - ✅ Cached images and files
   - ✅ Download history (optional)
   - ✅ Autofill form data (optional)
5. Click **"Clear data"** or **"Clear now"**
6. **Close the browser completely**
7. **Wait 10 seconds**
8. **Reopen browser**
9. Navigate to `http://localhost:8080`
10. Should show "Tallman Application Selector"!

### Solution 2: Use Private/Incognito Mode (Temporary Test)
This bypasses cache entirely:

**Chrome/Edge:**
- Press `Ctrl + Shift + N`

**Firefox:**
- Press `Ctrl + Shift + P`

Then navigate to `http://localhost:8080`

If it works in private mode but not regular mode → **Confirms browser cache issue**

### Solution 3: Try a Different Browser
If you've been using Chrome, try:
- Microsoft Edge
- Firefox
- Brave

A fresh browser has no cache for localhost:8080

### Solution 4: Clear Browser Cache via Windows Settings

**For Microsoft Edge:**
1. Close Edge completely
2. Open File Explorer
3. Navigate to: `C:\Users\BobM\AppData\Local\Microsoft\Edge\User Data\Default\Cache`
4. Delete everything in that folder
5. Navigate to: `C:\Users\BobM\AppData\Local\Microsoft\Edge\User Data\Default\Code Cache`
6. Delete everything in that folder
7. Reopen Edge

**For Chrome:**
1. Close Chrome completely
2. Open File Explorer
3. Navigate to: `C:\Users\BobM\AppData\Local\Google\Chrome\User Data\Default\Cache`
4. Delete everything in that folder
5. Navigate to: `C:\Users\BobM\AppData\Local\Google\Chrome\User Data\Default\Code Cache`
6. Delete everything in that folder
7. Reopen Chrome

### Solution 5: Disable Cache in DevTools
1. Open browser to `http://localhost:8080`
2. Press `F12` (open Developer Tools)
3. Go to **Network** tab
4. Check **"Disable cache"** checkbox (at top of Network tab)
5. Keep DevTools open
6. Press `Ctrl + F5` to reload
7. Watch the Network tab to see what's actually loading

This will show you:
- The actual files being requested
- The responses from IIS
- Whether they're coming from cache or server

### Solution 6: Add Cache-Busting Parameter
Navigate to:
```
http://localhost:8080/?nocache=123456
```

The `?nocache=123456` parameter tricks the browser into thinking it's a different URL.

Try different numbers each time:
- `http://localhost:8080/?v=1`
- `http://localhost:8080/?v=2`
- `http://localhost:8080/?refresh=true`

### Solution 7: Check if Multiple Sites Exist on Port 8080

Run this to verify only ONE site is on 8080:
```powershell
powershell -ExecutionPolicy Bypass -Command "Import-Module WebAdministration; Get-Website | Where-Object {$_.Bindings.Collection.bindingInformation -like '*:8080:*'} | Select-Object Name, PhysicalPath, State"
```

Should only show ONE site pointing to the dist folder.

---

## Verification Steps

After clearing cache, verify you're seeing the RIGHT application:

### Expected Signs of Correct App:
- ✅ Title: "Tallman Application Selector"
- ✅ Header shows "TALLMAN Equipment"
- ✅ Red and blue logo with "T"
- ✅ "Corporate Portal" text in header
- ✅ "Welcome, Team Member" message

### Signs of Wrong/Cached App:
- ❌ Title: "Dashboard" or something else
- ❌ Different branding
- ❌ Old interface

---

## Why This Happens

Browser caching for localhost:8080 is very aggressive because:
1. Browsers assume static assets don't change frequently
2. The same port may have served different applications
3. Browser doesn't know the files changed on the server

The `web.config` now includes cache-control headers to prevent this in the future:
```xml
<add name="Cache-Control" value="no-cache, no-store, must-revalidate" />
```

But this only affects NEW requests - cached pages ignore these headers until the cache is cleared.

---

## Quick Test Command

To verify IIS is serving the correct file:
```powershell
Invoke-WebRequest -Uri "http://localhost:8080" -UseBasicParsing | Select-Object -ExpandProperty Content | Select-String "Tallman Application Selector"
```

If this shows "Tallman Application Selector", IIS is correct → Browser cache is the problem.

---

## Last Resort: Reset IIS Bindings

If nothing works, the port might be serving a different site:

1. Run `CHECK-IIS-ADMIN.bat` to see all sites
2. Stop any other sites on port 8080
3. Ensure only "AppSelector" site is on 8080

---

**Bottom Line:** IIS is correct. Your browser needs its cache nuked!
