# Domain Setup Guide - apps.tallman.com

This guide explains how to set up domain name access (apps.tallman.com) for the AppSelector application.

## Overview

By default, the application runs on:
- **Development**: `http://localhost:3110`
- **Production**: `http://localhost:8080` or custom port

After following this guide, you'll be able to access it via:
- **Domain**: `http://apps.tallman.com` (port 80)
- **Or**: `http://apps.tallman.com:8080` (custom port)

---

## Prerequisites

✅ IIS site must be created and working  
✅ Application must be accessible via localhost  
✅ Run scripts as **Administrator**

---

## Setup Methods

Choose based on your environment:

### Method 1: Local Testing (Single Machine)

Use this for testing on the same machine where the app is installed.

**Steps:**

1. **Add to Windows Hosts File** (Run as Admin)
   ```
   Right-click: ADD-HOSTS-ENTRY.bat → Run as administrator
   ```
   - Choose option 1 (127.0.0.1)
   - This adds: `127.0.0.1    apps.tallman.com` to `C:\Windows\System32\drivers\etc\hosts`

2. **Add IIS Domain Binding** (Run as Admin)
   ```
   Right-click: ADD-DOMAIN-BINDING.bat → Run as administrator
   ```
   - Choose your preferred port (recommend port 80 for production)

3. **Restart IIS**
   ```
   Right-click: RESTART-IIS-SITE.bat → Run as administrator
   ```

4. **Test Access**
   - Open browser: `http://apps.tallman.com`
   - Should load the AppSelector application

---

### Method 2: Network Access (Multiple Machines)

Use this when accessing from other computers on the network.

**Steps:**

1. **Configure DNS** (On DNS Server)
   - Add A record: `apps.tallman.com` → Server IP address
   - Example: `apps.tallman.com` → `192.168.1.100`

2. **Add IIS Domain Binding** (Run as Admin on web server)
   ```
   Right-click: ADD-DOMAIN-BINDING.bat → Run as administrator
   ```
   - Choose your preferred port

3. **Configure Firewall** (On web server)
   ```powershell
   # Allow port 80
   New-NetFirewallRule -DisplayName "AppSelector HTTP" -Direction Inbound -Protocol TCP -LocalPort 80 -Action Allow
   
   # Or allow port 8080
   New-NetFirewallRule -DisplayName "AppSelector HTTP 8080" -Direction Inbound -Protocol TCP -LocalPort 8080 -Action Allow
   ```

4. **Restart IIS**
   ```
   Right-click: RESTART-IIS-SITE.bat → Run as administrator
   ```

5. **Test Access**
   - From any network computer: `http://apps.tallman.com`

---

### Method 3: Production Domain (Internet Access)

Use this for public internet access with proper DNS.

**Steps:**

1. **Register Domain** (If not already owned)
   - Domain registrar (Godaddy, Namecheap, etc.)
   - Subdomain: `apps.tallman.com`

2. **Configure External DNS**
   - Add A record pointing to your public IP
   - Example: `apps.tallman.com` → `203.0.113.45`

3. **Configure Port Forwarding** (On router/firewall)
   - Forward external port 80 → internal server port 80
   - Forward external port 443 → internal server port 443 (for HTTPS)

4. **Add IIS Domain Binding**
   ```
   Right-click: ADD-DOMAIN-BINDING.bat → Run as administrator
   ```

5. **Set Up SSL/HTTPS** (Recommended for production)
   - Obtain SSL certificate (Let's Encrypt, commercial CA)
   - Install certificate in IIS
   - Add HTTPS binding on port 443

6. **Test Access**
   - From internet: `http://apps.tallman.com`
   - With SSL: `https://apps.tallman.com`

---

## Port Selection

| Port | Use Case | Pros | Cons |
|------|----------|------|------|
| **80** | Production HTTP | Clean URLs, no port number needed | May conflict with other sites |
| **8080** | Alternative HTTP | Avoids conflicts | Requires `:8080` in URL |
| **443** | Production HTTPS | Secure, clean URLs | Requires SSL certificate |

**Recommendation**: Use port 80 for production, port 8080 for testing.

---

## Scripts Overview

### ADD-HOSTS-ENTRY.bat
- Adds domain to Windows hosts file
- For local testing only
- Creates backup before modifying

### ADD-DOMAIN-BINDING.bat
- Adds domain binding to IIS site
- Works with any port (80, 8080, etc.)
- Can add multiple bindings

### RESTART-IIS-SITE.bat
- Restarts the AppSelector IIS site
- Apply changes after configuration

---

## Troubleshooting

### Problem: "Cannot resolve apps.tallman.com"

**Solution:**
```powershell
# Test DNS
nslookup apps.tallman.com

# If fails, check hosts file
notepad C:\Windows\System32\drivers\etc\hosts

# Flush DNS cache
ipconfig /flushdns
```

---

### Problem: "Site not accessible from network"

**Solution:**
```powershell
# Check firewall
Get-NetFirewallRule -DisplayName "*AppSelector*"

# Check IIS bindings
Import-Module WebAdministration
Get-WebBinding -Name "AppSelector"

# Test port from another machine
Test-NetConnection -ComputerName SERVER_IP -Port 80
```

---

### Problem: "Wrong site appears"

**Solution:**
1. Check IIS bindings - may have conflicting hostname bindings
2. Ensure Default Web Site doesn't capture the request
3. Verify AppSelector site is running
4. Check browser cache - try incognito mode

---

### Problem: "403 Forbidden" or "404 Not Found"

**Solution:**
```powershell
# Check IIS physical path
Get-WebSite -Name "AppSelector" | Select-Object Name, PhysicalPath

# Should be: C:\Users\BobM\TallmanApps\AppSelector\dist

# Fix if needed
Right-click: FIX-IIS-PATH.bat → Run as administrator
```

---

## Verification Checklist

After setup, verify:

- [ ] DNS resolves correctly: `nslookup apps.tallman.com`
- [ ] Can ping domain: `ping apps.tallman.com`
- [ ] IIS binding exists: Check IIS Manager
- [ ] Site returns correct content (not blank/error)
- [ ] Backend API works: Test app functionality
- [ ] Works in multiple browsers
- [ ] Works from other machines (if network setup)

---

## Removing Domain Configuration

### Remove Hosts File Entry

1. **Edit hosts file as Administrator**
   ```
   notepad C:\Windows\System32\drivers\etc\hosts
   ```

2. **Delete the line:**
   ```
   127.0.0.1    apps.tallman.com
   ```

3. **Save and flush DNS**
   ```
   ipconfig /flushdns
   ```

### Remove IIS Binding

```powershell
# As Administrator
Import-Module WebAdministration
Remove-WebBinding -Name "AppSelector" -Protocol "http" -HostHeader "apps.tallman.com"
```

Or use IIS Manager: Site → Bindings → Select and Remove

---

## Security Considerations

### For Production Deployment:

1. **Use HTTPS** - Never send sensitive data over HTTP
2. **SSL Certificate** - Obtain valid SSL certificate
3. **Firewall Rules** - Only open necessary ports
4. **Access Control** - Implement authentication if needed
5. **Regular Updates** - Keep IIS and Windows updated
6. **Backup** - Regular backups of configuration and data

---

## Additional Resources

- **Production Setup**: See `PRODUCTION-SETUP.md`
- **Port Configuration**: See `PORT-RECOMMENDATIONS.md`
- **IIS Troubleshooting**: See `REAL-SOLUTION-IIS-PATH.md`
- **Browser Issues**: See `SOLUTION-BROWSER-CACHE-ISSUE.md`

---

## Quick Start (Local Testing)

### HTTP Only (Simple Setup):

```cmd
1. Right-click ADD-HOSTS-ENTRY.bat → Run as administrator
   - Choose option 1 (127.0.0.1)

2. Right-click ADD-DOMAIN-BINDING.bat → Run as administrator
   - Choose option 1 (port 80)

3. Right-click RESTART-IIS-SITE.bat → Run as administrator

4. Open browser: http://apps.tallman.com
```

Done! ✅

### HTTPS (Secure Setup):

```cmd
1. Right-click ADD-HOSTS-ENTRY.bat → Run as administrator
   - Choose option 1 (127.0.0.1)

2. Right-click CREATE-SELF-SIGNED-CERT.bat → Run as administrator
   - Creates SSL certificate for apps.tallman.com

3. Right-click ADD-DOMAIN-BINDING.bat → Run as administrator
   - Choose option 1 (port 80) for HTTP

4. Right-click ADD-HTTPS-BINDING.bat → Run as administrator
   - Choose option 1 (port 443) for HTTPS

5. (Optional) Right-click ENABLE-HTTPS-REDIRECT.bat
   - Automatically redirects HTTP to HTTPS

6. Right-click RESTART-IIS-SITE.bat → Run as administrator

7. Open browser: https://apps.tallman.com
```

Done! ✅ (Secure with SSL)

---

## HTTPS/SSL Setup

### Self-Signed Certificate (Development/Testing)

**When to Use:**
- Local development and testing
- Internal network applications
- Learning/experimentation

**Steps:**

1. **Create Certificate**
   ```
   Right-click: CREATE-SELF-SIGNED-CERT.bat → Run as administrator
   ```
   - Generates 5-year certificate
   - Automatically added to Trusted Root on this machine
   - Exported to `certs/apps.tallman.com.cer`

2. **Add HTTPS Binding**
   ```
   Right-click: ADD-HTTPS-BINDING.bat → Run as administrator
   ```
   - Binds certificate to IIS site
   - Choose port 443 (standard) or 8443 (alternative)

3. **Enable Auto-Redirect (Optional)**
   ```
   Right-click: ENABLE-HTTPS-REDIRECT.bat
   ```
   - Redirects HTTP → HTTPS automatically

4. **Test**
   ```
   https://apps.tallman.com
   ```

**Notes:**
- ✅ No warnings on the machine where certificate was created
- ⚠️ Other machines will show "Not Secure" warnings
- To fix: Import `certs/apps.tallman.com.cer` to Trusted Root on each machine

---

### Commercial Certificate (Production)

**When to Use:**
- Public internet-facing sites
- Production environments
- When users should not see warnings

**Options:**

1. **Free: Let's Encrypt**
   - Automated, renewable certificates
   - Trusted by all browsers
   - Requires domain accessible from internet
   - See: `SSL-COMMERCIAL-SETUP.md` for setup guide

2. **Paid: Commercial CA**
   - DigiCert, Sectigo, GoDaddy, etc.
   - Annual cost ($50-$300+)
   - Extended validation options
   - See: `SSL-COMMERCIAL-SETUP.md` for setup guide

**General Steps:**
1. Generate Certificate Signing Request (CSR)
2. Submit CSR to Certificate Authority
3. Verify domain ownership
4. Download and install certificate
5. Bind certificate in IIS
6. Test HTTPS access

For detailed instructions, see `SSL-COMMERCIAL-SETUP.md`

---

## Support

If you encounter issues:

1. Check the troubleshooting section above
2. Review IIS event logs: Event Viewer → Windows Logs → Application
3. Check browser console for JavaScript errors (F12)
4. Verify both frontend (IIS) and backend (service) are running

---

**Last Updated**: December 10, 2025  
**Version**: 1.0.0
