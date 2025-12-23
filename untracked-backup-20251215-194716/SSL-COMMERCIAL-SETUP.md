# Commercial SSL Certificate Setup Guide

This guide explains how to obtain and install a commercial SSL certificate from a trusted Certificate Authority (CA) for production use.

---

## Why Commercial Certificates?

### Self-Signed vs Commercial Certificates

| Feature | Self-Signed | Commercial (Paid) | Let's Encrypt (Free) |
|---------|-------------|-------------------|---------------------|
| **Cost** | Free | $50-$300+/year | Free |
| **Trust** | Not trusted by browsers | Trusted by all browsers | Trusted by all browsers |
| **Setup** | Simple, instant | Complex, manual | Automated |
| **Validity** | Any duration | 1-2 years | 90 days (auto-renew) |
| **Best For** | Development/Testing | Enterprise, EV certs | Most production sites |
| **Support** | None | Vendor support | Community |

---

## Option 1: Let's Encrypt (Recommended for Most Cases)

### Overview

- **Free, automated SSL certificates**
- Trusted by all major browsers
- 90-day certificates (auto-renewed)
- Perfect for most production scenarios

### Requirements

✅ Domain must be publicly accessible from internet  
✅ Port 80 or 443 accessible for validation  
✅ Administrative access to web server

### Setup with Certify The Web (Windows IIS)

**Recommended tool for Windows/IIS**

1. **Download Certify The Web**
   - Visit: https://certifytheweb.com/
   - Free for up to 5 certificates
   - Download and install

2. **Run Certify The Web**
   - Launch application
   - Click "New Certificate"

3. **Configure Certificate**
   ```
   - Select IIS Site: "AppSelector"
   - Primary Domain: apps.tallman.com
   - Authorization: HTTP-01 Challenge
   - Auto-bind to IIS: Yes
   ```

4. **Request Certificate**
   - Click "Request Certificate"
   - Let's Encrypt will validate domain ownership
   - Certificate automatically installed to IIS

5. **Auto-Renewal**
   - Certify The Web automatically renews before expiry
   - Runs as Windows background task
   - No manual intervention needed

6. **Verify**
   ```
   https://apps.tallman.com
   ```

### Setup with win-acme (Command Line Alternative)

**Free, command-line tool**

1. **Download win-acme**
   ```
   https://github.com/win-acme/win-acme/releases
   ```

2. **Run as Administrator**
   ```cmd
   wacs.exe
   ```

3. **Choose Option**
   ```
   N: Create certificate (simple for IIS)
   ```

4. **Select Site**
   ```
   Choose: AppSelector
   ```

5. **Follow Prompts**
   - Validates domain automatically
   - Installs to IIS
   - Sets up auto-renewal task

---

## Option 2: Paid Commercial Certificate

### Popular Certificate Authorities

1. **DigiCert**
   - Premium brand
   - $200-$1000+/year
   - Best support
   - https://www.digicert.com/

2. **Sectigo (formerly Comodo)**
   - Mid-range pricing
   - $50-$250/year
   - Good for most businesses
   - https://sectigo.com/

3. **GoDaddy**
   - Budget option
   - $70-$300/year
   - Easy for small businesses
   - https://www.godaddy.com/

4. **GlobalSign**
   - Enterprise focus
   - $250-$700/year
   - International reach
   - https://www.globalsign.com/

### Certificate Types

1. **Domain Validation (DV)**
   - Cheapest ($50-$100/year)
   - Validates domain ownership only
   - Good for: Small sites, blogs

2. **Organization Validation (OV)**
   - Mid-range ($100-$250/year)
   - Validates organization identity
   - Good for: Business sites

3. **Extended Validation (EV)**
   - Most expensive ($200-$1000+/year)
   - Highest validation level
   - Shows company name in browser
   - Good for: E-commerce, banking

### Purchase and Installation Steps

#### Step 1: Generate Certificate Signing Request (CSR)

1. **Open IIS Manager**
   ```
   Start → Run → inetmgr
   ```

2. **Server Certificates**
   - Server node (not site)
   - Double-click "Server Certificates"

3. **Create Certificate Request**
   - Right panel → "Create Certificate Request"
   
4. **Fill Details**
   ```
   Common Name: apps.tallman.com
   Organization: Your Company Name
   Organizational Unit: IT Department (optional)
   City: Your City
   State: Your State (full name, not abbreviation)
   Country: US (two-letter code)
   ```

5. **Cryptographic Settings**
   ```
   Cryptographic Service Provider: Microsoft RSA SChannel
   Bit Length: 2048 (or 4096 for more security)
   ```

6. **Save CSR File**
   ```
   Save to: C:\Users\BobM\TallmanApps\AppSelector\certs\request.csr
   ```

7. **Keep Private Key Safe**
   - IIS keeps private key automatically
   - Do not regenerate CSR or you'll lose the key!

#### Step 2: Purchase Certificate

1. **Choose CA and Certificate Type**
   - Select from vendors above
   - Choose DV, OV, or EV based on needs

2. **Submit CSR**
   - During purchase, you'll paste CSR content
   - Open `request.csr` in Notepad
   - Copy entire content including BEGIN/END lines

3. **Validate Domain Ownership**
   
   **Method A: Email Validation**
   - CA sends email to admin@tallman.com or similar
   - Click validation link in email
   
   **Method B: HTTP File Validation**
   - CA provides file to upload
   - Upload to: `http://apps.tallman.com/.well-known/pki-validation/`
   
   **Method C: DNS Validation**
   - CA provides DNS TXT record
   - Add to DNS: `_validation.apps.tallman.com`

4. **Download Certificate**
   - After validation, download certificate
   - Choose format: "IIS" or "PFX/PKCS#12"
   - You'll receive:
     - Certificate file (.cer or .crt)
     - Intermediate certificate (CA bundle)
     - Root certificate

#### Step 3: Install Certificate in IIS

1. **Complete Certificate Request**
   
   **If received as .cer file:**
   ```
   IIS Manager
   → Server Certificates
   → Right panel → "Complete Certificate Request"
   → Select downloaded .cer file
   → Friendly name: "apps.tallman.com SSL"
   → Certificate store: "Web Hosting"
   → OK
   ```

   **If received as .pfx file:**
   ```
   IIS Manager
   → Server Certificates
   → Right panel → "Import"
   → Select .pfx file
   → Enter password (if any)
   → Certificate store: "Web Hosting"
   → OK
   ```

2. **Install Intermediate Certificates**
   - If provided separately, import intermediate/root certs
   - Use Windows Certificate Manager (certmgr.msc)
   - Import to "Intermediate Certification Authorities"

#### Step 4: Bind Certificate to IIS Site

1. **IIS Manager → Sites → AppSelector**
   
2. **Edit Bindings**
   ```
   Right panel → Bindings
   → Add (or Edit existing HTTPS binding)
   ```

3. **Configure HTTPS Binding**
   ```
   Type: https
   IP Address: All Unassigned
   Port: 443
   Host name: apps.tallman.com
   SSL Certificate: Select "apps.tallman.com SSL"
   ```

4. **Require SNI (if multiple certificates)**
   ```
   ☑ Require Server Name Indication
   ```

5. **OK to save**

#### Step 5: Test Certificate

1. **Restart IIS**
   ```
   Right-click: RESTART-IIS-SITE.bat → Run as administrator
   ```

2. **Test HTTPS Access**
   ```
   https://apps.tallman.com
   ```

3. **Verify Certificate**
   - Click padlock icon in browser
   - Check certificate details
   - Should show:
     - ✅ Valid certificate
     - ✅ Issued to: apps.tallman.com
     - ✅ Issued by: [Your CA]
     - ✅ No warnings

4. **Test SSL Configuration**
   - Visit: https://www.ssllabs.com/ssltest/
   - Enter: apps.tallman.com
   - Should achieve A or A+ rating

---

## Enable HTTP to HTTPS Redirect

After installing SSL certificate:

```
Right-click: ENABLE-HTTPS-REDIRECT.bat
```

This automatically redirects all HTTP traffic to HTTPS.

---

## Certificate Renewal

### Let's Encrypt
- **Auto-renews** every 60 days (expires after 90)
- No action needed if using Certify The Web or win-acme

### Commercial Certificates
- **Manual renewal** required before expiry
- CA sends reminder emails
- Purchase renewal (often discounted)
- Generate new CSR or reuse existing
- Follow same installation steps

### Renewal Checklist

30 days before expiry:
- [ ] Purchase renewal from CA
- [ ] Submit CSR (can reuse if same server)
- [ ] Complete validation
- [ ] Download new certificate
- [ ] Install new certificate in IIS
- [ ] Verify HTTPS works
- [ ] Update any intermediate certificates

---

## Troubleshooting

### Certificate Not Showing in Binding Dropdown

**Cause**: Certificate not in correct store or missing private key

**Solution**:
```powershell
# Check certificate location
Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object { $_.Subject -like "*apps.tallman.com*" }

# Verify private key exists
Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object { $_.HasPrivateKey -eq $true }
```

### Browser Shows "Not Secure" Warning

**Causes**:
1. Certificate expired
2. Domain mismatch (cert for wrong domain)
3. Missing intermediate certificates
4. Mixed content (HTTPS page loading HTTP resources)

**Solution**:
```
Check browser console (F12) for specific errors
Verify certificate is valid and matches domain
Install intermediate certificates
Ensure all resources load via HTTPS
```

### Certificate Chain Error

**Cause**: Missing intermediate certificates

**Solution**:
1. Download intermediate certificate from CA
2. Open `certmgr.msc` (Windows Certificate Manager)
3. Import to "Intermediate Certification Authorities"
4. Restart IIS

---

## Security Best Practices

1. **Use Strong Cipher Suites**
   - Disable SSLv3, TLS 1.0, TLS 1.1
   - Enable TLS 1.2 and TLS 1.3
   - Configure via IIS Crypto tool

2. **Enable HSTS** (HTTP Strict Transport Security)
   - Prevents downgrade attacks
   - Add to web.config

3. **Keep Certificates Updated**
   - Set calendar reminders
   - Monitor expiry dates
   - Renew 30 days early

4. **Protect Private Keys**
   - Never share or export unnecessarily
   - Use strong key lengths (2048 or 4096 bit)
   - Regenerate if compromised

5. **Regular Security Scans**
   - Use SSL Labs test
   - Fix any issues found
   - Maintain A rating or higher

---

## Scripts Reference

- `CREATE-SELF-SIGNED-CERT.bat` - Development certificates
- `ADD-HTTPS-BINDING.bat` - Bind certificate to IIS
- `ENABLE-HTTPS-REDIRECT.bat` - Redirect HTTP to HTTPS
- `RESTART-IIS-SITE.bat` - Restart IIS after changes

---

## Quick Reference

### Certificate File Extensions

- **.cer / .crt** - Certificate (public key)
- **.key** - Private key
- **.csr** - Certificate signing request
- **.pfx / .p12** - Certificate + private key (password protected)
- **.pem** - Base64 encoded certificate

### Common Ports

- **80** - HTTP (unencrypted)
- **443** - HTTPS (SSL/TLS encrypted)
- **8080** - Alternative HTTP
- **8443** - Alternative HTTPS

---

## Cost Comparison (Annual)

| Option | Cost | Effort | Renewal |
|--------|------|--------|---------|
| **Self-Signed** | $0 | Low | Manual |
| **Let's Encrypt** | $0 | Medium (initial) | Automatic |
| **Commercial DV** | $70-$100 | Medium | Annual |
| **Commercial OV** | $150-$250 | High | Annual |
| **Commercial EV** | $300-$1000+ | Very High | Annual |

**Recommendation for AppSelector**: 
- Development: Self-signed
- Production (Internal): Self-signed or Let's Encrypt
- Production (Public): Let's Encrypt or Commercial DV

---

## Additional Resources

- Let's Encrypt: https://letsencrypt.org/
- Certify The Web: https://certifytheweb.com/
- SSL Labs Test: https://www.ssllabs.com/ssltest/
- IIS SSL Configuration: https://learn.microsoft.com/en-us/iis/manage/configuring-security/how-to-set-up-ssl-on-iis

---

**Last Updated**: December 10, 2025  
**Version**: 1.0.0
