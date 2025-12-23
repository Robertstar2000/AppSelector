# Production Setup - What to Keep Running

## Current Issue

Right now, **Node.js is serving port 8080** (wrong for production).

For production, you need:
- **IIS** serving frontend on `http://localhost:8080`
- **Backend Node.js** server on `http://localhost:3000`

---

## Step 1: Switch from Node.js to IIS on Port 8080

**Run:** `FIX-PORT-8080-CONFLICT.bat` (as Administrator)

This will:
1. Kill Node.js on port 8080
2. Start IIS site on port 8080

---

## Step 2: Start Backend Server

After fixing port 8080, start the backend:

```bash
npm run dev:backend
```

Or:
```bash
node backend/server.cjs
```

**Keep this terminal window open!** The backend must run continuously.

---

## Production Architecture

```
┌─────────────────────────────────────────┐
│  Users Access                           │
│  http://localhost:8080                  │
└────────────┬────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────┐
│  IIS (Port 8080)                        │
│  Serves: dist/ (React frontend)         │
│  - index.html                           │
│  - JavaScript bundles                   │
│  - Static assets                        │
└─────────────────────────────────────────┘
             │
             │ API calls to /api/*
             ▼
┌─────────────────────────────────────────┐
│  Node.js Backend (Port 3000)            │
│  File: backend/server.cjs               │
│  - Database (apps.db)                   │
│  - API endpoints                        │
│  - File backups                         │
└─────────────────────────────────────────┘
```

---

## What Needs to Run Always

### 1. IIS Service (Frontend)
**Status:** Runs automatically as Windows service
- Starts on boot
- No manual start needed
- Serves from `C:\Users\BobM\TallmanApps\AppSelector\dist`

**To check:**
```powershell
Get-Service W3SVC
```

**To restart if needed:**
```powershell
iisreset /restart
```

### 2. Backend Node.js Server
**Status:** Must be manually started OR set up as Windows service

**Option A: Manual Start (Development/Testing)**
```bash
cd C:\Users\BobM\TallmanApps\AppSelector
npm run dev:backend
```
**Keep the terminal open!**

**Option B: Windows Service (Production - Recommended)**

You already have `setup-service.bat` and `setup-service.ps1`!

**To install backend as Windows service:**
1. Run `setup-service.bat` as Administrator
2. Backend will start automatically on boot
3. Runs in background, no terminal needed

**To check service:**
```powershell
Get-Service -Name "AppSelectorBackend"
```

---

## Quick Start Commands

### After Reboot (if backend NOT a service):
```bash
cd C:\Users\BobM\TallmanApps\AppSelector
npm run dev:backend
```

### After Code Changes:
```bash
# Rebuild frontend
npm run build

# Restart IIS to pick up new files
iisreset /restart

# Backend automatically picks up changes if using nodemon
# Otherwise restart: npm run dev:backend
```

---

## URLs

| Environment | Frontend | Backend | Notes |
|-------------|----------|---------|-------|
| **Production** | `http://localhost:8080` | `http://localhost:3001` | IIS + Backend service |
| **Production (Domain)** | `http://apps.tallman.com` | `http://localhost:3001` | Domain access (see below) |
| **Development** | `http://localhost:3110` | `http://localhost:3001` | `npm run dev` |

---

## Domain Access Setup (apps.tallman.com)

To access the application using **apps.tallman.com** instead of localhost:

### HTTP Setup (Simple):

1. **Add to hosts file** (Run as Admin)
   ```
   Right-click: ADD-HOSTS-ENTRY.bat → Run as administrator
   ```

2. **Add IIS binding** (Run as Admin)
   ```
   Right-click: ADD-DOMAIN-BINDING.bat → Run as administrator
   ```

3. **Restart IIS**
   ```
   Right-click: RESTART-IIS-SITE.bat → Run as administrator
   ```

4. **Access via domain**
   ```
   http://apps.tallman.com
   ```

### HTTPS Setup (Secure - Recommended for Production):

1. **Add to hosts file** (Run as Admin)
   ```
   Right-click: ADD-HOSTS-ENTRY.bat → Run as administrator
   ```

2. **Create SSL certificate** (Run as Admin)
   ```
   Right-click: CREATE-SELF-SIGNED-CERT.bat → Run as administrator
   ```

3. **Add HTTP binding** (Run as Admin)
   ```
   Right-click: ADD-DOMAIN-BINDING.bat → Run as administrator
   Choose port 80
   ```

4. **Add HTTPS binding** (Run as Admin)
   ```
   Right-click: ADD-HTTPS-BINDING.bat → Run as administrator
   Choose port 443
   ```

5. **Enable auto-redirect** (Optional)
   ```
   Right-click: ENABLE-HTTPS-REDIRECT.bat
   Automatically redirects HTTP to HTTPS
   ```

6. **Restart IIS**
   ```
   Right-click: RESTART-IIS-SITE.bat → Run as administrator
   ```

7. **Access via secure domain**
   ```
   https://apps.tallman.com
   ```

📖 **For detailed instructions, see:**
- Domain Setup: `DOMAIN-SETUP-GUIDE.md`
- SSL/HTTPS: `SSL-COMMERCIAL-SETUP.md`

---

## Browser Extension Issue

Your regular browser shows Copilot due to an extension. Options:

### Fix 1: Disable Extension
1. Browser Settings → Extensions
2. Find and disable Microsoft Copilot or any localhost-redirecting extensions
3. Reload `http://localhost:8080`

### Fix 2: Use Different Browser
Use a browser without Copilot extension (Firefox, Chrome without extensions)

### Fix 3: Use Incognito Mode
Keep using `Ctrl + Shift + N` for testing (works perfectly)

---

## Maintenance

### Daily Operation
- IIS: Runs automatically
- Backend:
  - If service: Runs automatically
  - If manual: Run `npm run dev:backend`

### After Updates
```bash
# Rebuild frontend
npm run build

# Restart IIS
iisreset /restart

# Restart backend service (if using service)
Restart-Service AppSelectorBackend
```

### Troubleshooting
```bash
# Check what's on port 8080
netstat -ano | findstr ":8080"

# Check IIS site
# Run as Admin: CHECK-IIS-ADMIN.bat

# Test what port 8080 serves
powershell -ExecutionPolicy Bypass -File test-port-8080.ps1
```

---

## Recommended Production Setup

1. **Install backend as Windows service**
   ```
   Run: setup-service.bat (as Administrator)
   ```

2. **Everything runs automatically on boot:**
   - ✅ IIS (frontend on 8080)
   - ✅ Backend service (API on 3000)

3. **No terminals needed!**

4. **Fix browser extension** or use different browser

---

## Current Status

✅ Frontend working (serves "Tallman Application Selector")  
✅ Port 8080 active  
❌ Node.js on 8080 (should be IIS)  
❓ Backend service status unknown  
❌ Browser extension redirecting to Copilot  

**Next Step:** Run `FIX-PORT-8080-CONFLICT.bat` to switch to IIS, then start backend!
