# Tallman Equipment Company App Selector

A professional application launcher portal for managing and accessing multiple business applications through a unified interface.

## 🚀 Quick Start

### Prerequisites
- **Node.js** (v16 or higher)
- **npm** or **yarn**

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Robertstar2000/AppSelector.git
   cd AppSelector
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Start the application:**
   ```bash
   npm run dev
   ```

   This command starts both services concurrently:
   - **Frontend:** http://localhost:3110
   - **Backend API:** http://localhost:3001

## 📋 Features

### Core Functionality
- **Professional Interface:** Clean, corporate-themed application portal
- **Application Cards:** Intuitive card-based navigation for business applications
- **Search Feature:** Quickly find applications by name or description
- **Responsive Design:** Optimized for desktop and mobile devices

### Application Status System
- **Active:** Fully functional applications
- **Under Construction:** Temporarily unavailable but accessible (shows yellow "Under Construction" badge)
- **Disabled:** Completely unavailable (shows red "Not Yet Available" badge)

### Admin Management
- **Enter Admin Mode:** Click the version number (v1.0.0) in the footer 5 times
- **Application Management:** Add, edit, and delete applications
- **Drag & Drop Reordering:** Reorganize app positions (changes persist in database)
- **App Status Control:** Set applications to Active, Maintenance, or Disabled

### App Types Supported
- **URL Links:** External web applications
- **Executable Files (.exe):** Local Windows applications
- **Internal Views:** Custom application views

### Backup & Recovery
- **Auto-Backup:** Automatic data saving on app changes (when configured)
- **Manual Backup:** Download complete app data as JSON file
- **Restore Functionality:** Import saved backup files

## 🔧 Admin Mode Operations

### Accessing Admin Mode
1. Scroll to the bottom of the page
2. Click on the version number "v1.0.0" five times rapidly
3. Admin mode will activate (red indicator appears at top screen)

### Managing Applications

**Adding New Apps:**
- Access admin mode
- Click the "Add Application" button (+) at the bottom of the app grid
- Fill in app details and save

**Editing Existing Apps:**
- In admin mode, click on any application card to open edit dialog
- Modify details, status, and settings as needed

**Reordering Apps:**
- In admin mode, drag and drop app cards to rearrange positions
- Changes are automatically saved and will persist after page refresh

**App Status Options:**
- **Active:** Normal operation
- **Maintenance:** Shows warning badge but remains accessible
- **Disabled:** Shows unavailable badge and becomes non-clickable

### Backup Operations
1. Enter admin mode
2. Click the download icon in the top navigation bar
3. Choose between:
   - **Manual Download:** Immediate JSON export
   - **Restore Data:** Upload previously saved backup file

## 🗃️ Technical Architecture

### Backend (Express.js + SQLite3)
- **Server:** Node.js with Express.js
- **Database:** SQLite3 for local data persistence
- **API Endpoints:** RESTful API for app management
- **Port:** 3001

### Frontend (React + Vite)
- **Framework:** React with TypeScript
- **Build Tool:** Vite for fast development
- **Styling:** Tailwind CSS with custom Tallman brand colors
- **Icons:** Lucide React icon library
- **Port:** 3110

### Development Scripts
- `npm run dev` - Start both frontend and backend
- `npm run dev:frontend` - Start only frontend (Vite)
- `npm run dev:backend` - Start only backend (Express)
- `npm run build` - Build production bundle
- `npm run preview` - Preview production build

## 📊 Application Data Storage

- Apps are stored in a local SQLite database (`apps.db`)
- Position ordering is maintained for consistent UI layout
- Settings and backup configurations are persisted
- Database changes are reflected in GitHub repository

## 🛠️ Customization

### Adding Your Own Apps
1. Enter admin mode
2. Click "Add Application"
3. Configure:
   - Name and Description
   - Type (URL/EXE/Internal View)
   - URL or file path
   - Status (Active/Maintenance/Disabled)
   - Icon selection from Lucide library

### System Settings (via Backup Modal)
- Configure auto-backup file path
- Enable/disable automatic data saving
- Set backup file locations

## 🔐 Security Notes
- Admin mode provides full application management capabilities
- No authentication required (local application)
- SQLite database contains application metadata only
- Backup files may contain sensitive configuration data

## 🚨 Troubleshooting

**Admin mode won't activate:**
- Ensure you're clicking the version number exactly 5 times
- Try refreshing the page and attempting again

**Changes not saving:**
- Ensure the backend server is running (port 3001)
- Check browser console for error messages

**Backup/restore issues:**
- Verify file paths are correctly configured
- Check that backup files contain valid JSON data

**Drag and drop not working:**
- Must be in admin mode
- Search must be cleared for drag operations

---

**Version:** 1.0.0
**Last Updated:** December 2025
**Repository:** https://github.com/Robertstar2000/AppSelector
