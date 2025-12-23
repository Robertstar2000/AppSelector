# Development vs Production: Port 3110 vs Port 8080

## Quick Answer
**No, port 3110 is NOT running on IIS!**

There are two completely different setups:

---

## 🔧 Development Mode (Port 3110)

### Start Command:
```bash
npm run dev
```

### What Runs:
- **Frontend**: Vite Dev Server on `http://localhost:3110`
- **Backend**: Node.js Express on `http://localhost:3000`

### Server Details:
- ❌ **NOT IIS** - Uses Vite's built-in development server
- ✅ Hot Module Replacement (HMR) - changes appear instantly
- ✅ Fast refresh - no need to rebuild
- ✅ Source maps for debugging
- ✅ Development-only features

### When to Use:
- ✅ **During active development/coding**
- ✅ When you want instant feedback on code changes
- ✅ When debugging with source maps
- ❌ NOT for production deployment

---

## 🚀 Production Mode (Port 8080)

### Build Command:
```bash
npm run build
```

### What Runs:
- **Frontend**: IIS Server on `http://localhost:8080`
- **Backend**: Must be started separately with `npm run dev:backend` on `http://localhost:3000`

### Server Details:
- ✅ **IIS Server** - Windows production web server
- ✅ Serves optimized/minified files from `dist/` folder
- ✅ Uses `web.config` for IIS configuration
- ❌ No hot-reload - must rebuild after changes
- ❌ No source maps (production build)

### When to Use:
- ✅ **Testing production build**
- ✅ **Production deployment**
- ✅ When you need IIS-specific features
- ✅ When testing with production optimizations
- ❌ NOT for active development (too slow)

---

## 📊 Comparison Table

| Feature | Development (3110) | Production (8080) |
|---------|-------------------|-------------------|
| **Server** | Vite Dev Server | IIS |
| **Command** | `npm run dev` | `npm run build` + IIS |
| **Hot Reload** | ✅ Yes | ❌ No |
| **Speed** | ⚡ Very Fast | 🐢 Slower (rebuild needed) |
| **Source Maps** | ✅ Yes | ❌ No |
| **Optimized** | ❌ No | ✅ Yes (minified) |
| **Backend Auto-Start** | ✅ Yes | ❌ No (manual start) |
| **Use For** | Development | Production/Testing |

---

## 🎯 Your Current Issue

The React Router error you're experiencing is on:
- **Port 8080 (IIS Production Server)**

This is a **browser cache issue** where the browser cached old JavaScript code.

### To Test Development Mode (Should Work Fine):
1. Stop IIS if running
2. Run: `npm run dev`
3. Open: `http://localhost:3110`
4. Should work perfectly with no errors!

### To Fix Production Mode (Port 8080):
1. Run: `RUN-AS-ADMIN-FINAL-FIX.bat`
2. Clear browser cache (Ctrl+Shift+Delete)
3. Open: `http://localhost:8080`
4. Hard refresh (Ctrl+F5)

---

## 💡 Recommended Workflow

### Daily Development:
```bash
# Start development servers
npm run dev

# Access at http://localhost:3110
# Make changes - they appear instantly!
```

### Testing Production Build:
```bash
# Build for production
npm run build

# Start backend separately
npm run dev:backend

# Access at http://localhost:8080 (via IIS)
```

### Production Deployment:
```bash
# Build optimized version
npm run build

# Files in dist/ folder are deployed to IIS
# IIS serves on port 8080
# Backend runs as Windows Service or separate process
```

---

## 🔍 How to Check What's Running

### Check if Vite Dev Server is running (port 3110):
```bash
netstat -ano | findstr :3110
```

### Check if IIS is serving on port 8080:
```bash
netstat -ano | findstr :8080
```

### Check if backend is running (port 3000):
```bash
netstat -ano | findstr :3000
```

---

## ❓ FAQ

**Q: Can I run both at the same time?**
A: Yes! Development (3110) and Production (8080) can run simultaneously on different ports.

**Q: Which should I use for development?**
A: **Port 3110** (`npm run dev`) - It's MUCH faster with hot-reload!

**Q: When do I need IIS (port 8080)?**
A: Only for testing the production build or deploying to production.

**Q: Does port 3110 need the web.config file?**
A: No! `web.config` is only for IIS (port 8080). Vite dev server doesn't use it.

**Q: Why is port 8080 showing errors but 3110 works fine?**
A: Because port 8080 (IIS) is serving from the `dist/` folder, and your browser cached old files. Port 3110 (Vite) serves fresh source code every time.

---

**Summary**: Port 3110 uses Vite Dev Server for development. Port 8080 uses IIS for production. They are completely different servers!
