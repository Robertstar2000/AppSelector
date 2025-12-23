# Backup and Recovery System - Tallman Equipment Company App Selector

## Overview

The App Selector includes a comprehensive backup and recovery system that allows you to preserve and restore your application configuration. This system protects against data loss and enables easy transfer of app configurations between installations.

## How Backup Works

### Two Types of Backups

#### 1. Automatic Backup
- **Triggers when app changes are saved** (adding, editing, or reordering apps)
- **Requires configuration**: Must enable auto-backup AND set a backup file path
- **Stores data on server file system** at the configured backup path location
- **Browser-independent**: Backup persists regardless of which browser or device is used
- **Silent operation**: Happens in the background without user interaction

#### 2. Manual Backup
- **User-initiated export** of current app configuration
- **Downloads a JSON file** with all application data to your local machine
- **Updates auto-backup location** if auto-backup is enabled and configured
- **Immediately accessible** - no configuration required
- **Timestamped filename** for easy identification

## What Gets Backed Up

Each backup contains:

### Application Data
- All app cards with their properties:
  - ID, Name, Description
  - URL/File Path, Type (URL/EXE/Internal)
  - Status (Active/Maintenance/Disabled)
  - Icon, Source Code, Backend Location, Author
  - **Display Order (Position)** - Critical for maintaining custom layouts

### System Settings
- Auto-backup enabled/disabled
- Backup file path configuration
- Last backup timestamp

### Metadata
- Backup creation timestamp
- Format version information

## How Recovery Works

### Recovery Method

#### Restore from Server Auto-Backup
- **Access**: Admin Mode → Download Icon → "Restore Data"
- **Process**:
  1. Click "Restore Data" button (reads from server backup file)
  2. System retrieves backup from configured file path on server
  3. Confirm overwrite of current data
  4. System reloads with restored configuration

**Note**: Manual backup files can still be downloaded, but restoration now uses the server-stored auto-backup for consistency across all users and devices.

## Step-by-Step Guides

### Setting Up Backup Location

1. **Enter Admin Mode** (click version number 5 times)
2. **Open Backup Manager** (download icon in top-right)
3. **Set Backup File Path** (required for all backup operations):
   ```
   Examples:
   C:\Users\YourName\AppSelector\Backup\apps.json
   /home/user/backup/apps.json
   ```
4. **Optionally enable auto-backup** with the checkbox
5. **Save Settings**

### Creating Manual Backup

1. **Enter Admin Mode**
2. **Click Download Icon** in header
3. **Choose "Download Backup"**
4. **Two actions occur automatically:**
   - JSON file downloads to your browser
   - Backup is silently saved to the configured server path

### Restoring from Backup

**Restores from the configured backup path on the server:**

1. **Enter Admin Mode**
2. **Click Download Icon** in header
3. **Choose "Restore Data"**
4. **System reads from configured backup path** (no file selection needed)
5. **Confirm overwrite** when prompted
6. **Page reloads automatically** with restored data

**Note**: Restore only works with backups saved to the configured server path. No file dialog appears.

## Technical Details

### Data Storage Structure

```json
{
  "timestamp": "2025-12-07T13:45:30.123Z",
  "apps": [
    {
      "id": "example-app",
      "name": "Example Application",
      "description": "Sample app description",
      "iconName": "Settings",
      "url": "https://example.com",
      "status": "ACTIVE",
      "type": "URL",
      "position": 1
    }
  ],
  "settings": {
    "autoBackup": true,
    "backupFilePath": "C:\\Path\\To\\Backup"
  }
}
```

### Database Integration

- **SQLite Database**: `apps.db` stores current configuration
- **Backup Selection**: GET `/api/backup` exports current database state
- **Restore Process**: PUT `/api/apps` replaces all app data at once
- **Position Ordering**: Apps ordered by `position` field for consistent layout

### File Storage

- **Manual Backups**: Download as JSON files via browser to user's local machine
- **Auto-Backups**: Stored as JSON file on server file system at the configured backup path
  - File is written directly to the server file system using Node.js fs APIs
  - Path is configured by administrator and can be any accessible directory (e.g., `C:\Backup\Apps\` or `/home/user/backup/`)
  - Server creates backup file at the specified location with JSON data
  - Browser-independent - all users access the same backup data

## Important Notes

### What Backup Preserves
✅ App configurations and properties
✅ Custom display ordering (drag-and-drop positions)
✅ System settings and preferences
✅ Application statuses (Active/Maintenance/Disabled)

### What Backup Does NOT Include
❌ Actual application files (only metadata)
❌ User authentication data (none implemented)
❌ Browser caches or temporary data

### Safety Considerations
- **Always backup before major changes**
- **Restore operations are destructive** - they replace ALL current data
- **Backup file format is JSON** - human-readable and editable
- **Auto-backup requires valid file path** to be useful

### Troubleshooting

#### Auto-Backup Not Working
1. Ensure auto-backup is enabled in settings
2. Verify backup file path is set and accessible
3. Check browser console for error messages
4. Try manual backup as alternative

#### Restore Fails
1. Confirm backup file is valid JSON format
2. Ensure backup contains "apps" array
3. Check file permissions for write access
4. Try restarting application after restore

#### Missing App Ordering
1. Verify backup includes "position" fields in app data
2. Ensure database is ordered by position column
3. Try reordering and saving after restore

### Best Practices

1. **Regular Manual Backups**: Export periodically for safe keeping
2. **Before Major Changes**: Always backup before bulk operations
3. **Test Restore Process**: Verify backup files work by testing restoration
4. **Version Control Alternative**: Consider git commits for configuration changes
5. **Multiple Backup Copies**: Keep several historical backups

## Example Scenarios

### Scenario 1: Fresh Installation Setup
1. Configure auto-backup
2. Import previous backup
3. Verify apps appear in correct order

### Scenario 2: Hardware Migration
1. Export backup from old system
2. Install App Selector on new system
3. Import backup for identical configuration

### Scenario 3: Emergency Recovery
1. Something breaks app configuration
2. Use auto-backup data to restore
3. Or upload manual backup file if auto-backup unavailable

---

**Document Version:** 1.0
**Last Updated:** December 2025
**Application Version:** 1.0.0
