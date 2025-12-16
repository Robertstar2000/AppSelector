const express = require('express');
const sqlite3 = require('sqlite3').verbose();
const cors = require('cors');
const path = require('path');
const fs = require('fs').promises;

const app = express();
const PORT = process.env.PORT || 3001;

// Middleware
app.use(cors());
app.use(express.json());

// Serve static files from the React app build directory
app.use(express.static(path.join(__dirname, '..', 'dist')));

// Add this AFTER static files middleware to handle client-side routing
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, '..', 'dist', 'index.html'), (err) => {
    if (err) {
      console.error('Error sending index.html:', err);
      res.status(err.status || 500).end();
    }
  });
});

// Database setup
const dbPath = path.join(__dirname, '..', 'apps.db');
const db = new sqlite3.Database(dbPath);

// Initialize database
db.serialize(() => {
  // Create apps table
  db.run(`
    CREATE TABLE IF NOT EXISTS apps (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      description TEXT,
      iconName TEXT,
      url TEXT,
      status TEXT NOT NULL,
      type TEXT NOT NULL,
      sourceCode TEXT,
      backendLocation TEXT,
      author TEXT,
      position INTEGER
    )
  `);

  // Create system settings table
  db.run(`
    CREATE TABLE IF NOT EXISTS system_settings (
      key TEXT PRIMARY KEY,
      value TEXT
    )
  `);

  // Insert initial data if table is empty
  db.get('SELECT COUNT(*) as count FROM apps', (err, row) => {
    if (!err && row.count === 0) {
      const initialApps = [
        {
          id: 'agent',
          name: 'Agent',
          description: 'Field Agent Portal',
          iconName: 'UserCheck',
          url: 'https://agent.tallman.com',
          status: 'ACTIVE',
          type: 'URL'
        },
        {
          id: 'project',
          name: 'Project',
          description: 'Project Management Suite',
          iconName: 'Briefcase',
          url: 'https://project.tallman.com',
          status: 'ACTIVE',
          type: 'URL'
        },
        {
          id: 'dashboard',
          name: 'Dashboard',
          description: 'Executive KPI Overview',
          iconName: 'LayoutDashboard',
          url: 'https://dash.tallman.com',
          status: 'MAINTENANCE',
          type: 'URL'
        },
        {
          id: 'datahub',
          name: 'DataHub',
          description: 'Central Data Warehouse',
          iconName: 'Database',
          status: 'MAINTENANCE',
          type: 'URL'
        },
        {
          id: 'engineering',
          name: 'Engineering',
          description: 'CAD & Specs Library',
          iconName: 'DraftingCompass',
          status: 'MAINTENANCE',
          type: 'URL'
        },
        {
          id: 'buckettruck',
          name: 'BucketTruck',
          description: 'Fleet Management',
          iconName: 'Truck',
          url: 'C:\\Apps\\BucketTruck\\launcher.exe',
          status: 'MAINTENANCE',
          type: 'EXE'
        },
        {
          id: 'cascade',
          name: 'Cascade',
          description: 'Workflow Automation',
          iconName: 'Workflow',
          status: 'MAINTENANCE',
          type: 'URL'
        },
        {
          id: 'testing',
          name: 'Testing',
          description: 'QA & Safety Checks',
          iconName: 'TestTube',
          status: 'MAINTENANCE',
          type: 'URL'
        },
        {
          id: 'picklist',
          name: 'PickList',
          description: 'Warehouse Picking',
          iconName: 'ClipboardList',
          status: 'MAINTENANCE',
          type: 'URL'
        },
        {
          id: 'rubber',
          name: 'Rubber',
          description: 'Insulation Goods',
          iconName: 'Shield',
          status: 'MAINTENANCE',
          type: 'URL'
        },
        {
          id: 'rental',
          name: 'Rental',
          description: 'Equipment Rental Sys',
          iconName: 'CalendarClock',
          status: 'MAINTENANCE',
          type: 'URL'
        }
      ];

      const stmt = db.prepare('INSERT INTO apps (id, name, description, iconName, url, status, type) VALUES (?, ?, ?, ?, ?, ?, ?)');
      initialApps.forEach(app => {
        stmt.run(app.id, app.name, app.description, app.iconName, app.url, app.status, app.type);
      });
      stmt.finalize();
    }
  });
});

// API endpoints
// GET all apps
app.get('/api/apps', (req, res) => {
  db.all('SELECT * FROM apps ORDER BY position, id', (err, rows) => {
    if (err) {
      res.status(500).json({ error: err.message });
      return;
    }
    res.json(rows);
  });
});

// POST new app
app.post('/api/apps', (req, res) => {
  const { id, name, description, iconName, url, status, type, sourceCode, backendLocation, author, position } = req.body;

  // If position not provided, get next available position
  if (position === undefined || position === null) {
    db.get('SELECT MAX(position) as maxPos FROM apps', (err, row) => {
      if (err) {
        res.status(500).json({ error: err.message });
        return;
      }
      const nextPos = (row.maxPos || 0) + 1;

      const stmt = db.prepare('INSERT OR REPLACE INTO apps (id, name, description, iconName, url, status, type, sourceCode, backendLocation, author, position) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)');
      stmt.run(id, name, description, iconName, url, status, type, sourceCode, backendLocation, author, nextPos, function(err) {
        if (err) {
          res.status(500).json({ error: err.message });
          return;
        }
        res.json({ id, name, description, iconName, url, status, type, sourceCode, backendLocation, author, position: nextPos });
      });
      stmt.finalize();
    });
  } else {
    const stmt = db.prepare('INSERT OR REPLACE INTO apps (id, name, description, iconName, url, status, type, sourceCode, backendLocation, author, position) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)');
    stmt.run(id, name, description, iconName, url, status, type, sourceCode, backendLocation, author, position, function(err) {
      if (err) {
        res.status(500).json({ error: err.message });
        return;
      }
      res.json({ id, name, description, iconName, url, status, type, sourceCode, backendLocation, author, position });
    });
    stmt.finalize();
  }
});

// PUT update app
app.put('/api/apps/:id', (req, res) => {
  const { id } = req.params;
  const { name, description, iconName, url, status, type, sourceCode, backendLocation, author, position } = req.body;
  const stmt = db.prepare('UPDATE apps SET name = ?, description = ?, iconName = ?, url = ?, status = ?, type = ?, sourceCode = ?, backendLocation = ?, author = ?, position = ? WHERE id = ?');
  stmt.run(name, description, iconName, url, status, type, sourceCode, backendLocation, author, position, id, function(err) {
    if (err) {
      res.status(500).json({ error: err.message });
      return;
    }
    if (this.changes === 0) {
      res.status(404).json({ error: 'App not found' });
    } else {
      res.json({ id, name, description, iconName, url, status, type, sourceCode, backendLocation, author, position });
    }
  });
  stmt.finalize();
});

// DELETE app
app.delete('/api/apps/:id', (req, res) => {
  const { id } = req.params;
  const stmt = db.prepare('DELETE FROM apps WHERE id = ?');
  stmt.run(id, function(err) {
    if (err) {
      res.status(500).json({ error: err.message });
      return;
    }
    if (this.changes === 0) {
      res.status(404).json({ error: 'App not found' });
    } else {
      res.json({ message: 'App deleted' });
    }
  });
  stmt.finalize();
});

// GET backup data
app.get('/api/backup', (req, res) => {
  db.all('SELECT * FROM apps ORDER BY position, id', (err, rows) => {
    if (err) {
      res.status(500).json({ error: err.message });
      return;
    }

    const backupData = {
      timestamp: new Date().toISOString(),
      apps: rows
    };

    res.setHeader('Content-Disposition', `attachment; filename="apps-backup-${new Date().toISOString().split('T')[0]}.json"`);
    res.setHeader('Content-Type', 'application/json');
    res.end(JSON.stringify(backupData, null, 2));
  });
});

// Bulk update for reorder (PUT /api/apps)
app.put('/api/apps', (req, res) => {
  const apps = req.body;
  if (!Array.isArray(apps)) {
    res.status(400).json({ error: 'Expected array of apps' });
    return;
  }

  // Clear table and insert all
  db.serialize(() => {
    db.run('DELETE FROM apps', (err) => {
      if (err) {
        res.status(500).json({ error: err.message });
        return;
      }

      const stmt = db.prepare('INSERT INTO apps (id, name, description, iconName, url, status, type, sourceCode, backendLocation, author, position) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)');

      apps.forEach((app, index) => {
        stmt.run(app.id, app.name, app.description || '', app.iconName || 'Box', app.url, app.status, app.type, app.sourceCode, app.backendLocation, app.author, app.position ?? index);
      });

      stmt.finalize();

      res.json({ message: 'Apps updated', count: apps.length });
    });
  });
});

// Auto-backup endpoint (writes to server file system)
app.post('/api/auto-backup', async (req, res) => {
  try {
    // Get backup path from settings - only require path to be configured
    const backupPath = await new Promise((resolve, reject) => {
      db.get('SELECT value FROM system_settings WHERE key = ?', ['backup_file_path'], (err, row) => {
        if (err) reject(err);
        else resolve(row ? row.value : '');
      });
    });

    if (!backupPath.trim()) {
      return res.status(400).json({ error: 'Backup file path not configured' });
    }

    // Clean the backup path (remove quotes if present)
    const cleanBackupPath = backupPath.replace(/["']/g, '');
    console.log('Original backup path:', backupPath);
    console.log('Clean backup path:', cleanBackupPath);

    // Assume paths without file extensions are directories and append filename
    let finalBackupPath = cleanBackupPath;
    const hasFileExtension = path.extname(cleanBackupPath) !== '';
    const endsWithSeparator = cleanBackupPath.endsWith(path.sep) || cleanBackupPath.endsWith('/');

    if (!hasFileExtension) {
      // No file extension - treat as directory and append filename
      finalBackupPath = path.join(cleanBackupPath, 'apps-backup.json');
      console.log('No file extension, treating as directory:', finalBackupPath);
    } else if (endsWithSeparator) {
      // Ends with separator - treat as directory
      finalBackupPath = path.join(cleanBackupPath, 'apps-backup.json');
      console.log('Path ends with separator, treating as directory:', finalBackupPath);
    } else {
      // Has file extension - use as-is
      console.log('Path has file extension, using as filename:', finalBackupPath);
    }

    console.log('Final backup path to write:', finalBackupPath);

    // Ensure the backup directory exists
    const backupDir = path.dirname(finalBackupPath);
    console.log('Backup directory:', backupDir);
    await fs.mkdir(backupDir, { recursive: true });

    // Write backup data to file
    const { timestamp, apps, settings } = req.body;
    const backupData = { timestamp, apps, settings };
    await fs.writeFile(finalBackupPath, JSON.stringify(backupData, null, 2), 'utf8');

    // Update last backup date
    return new Promise((resolve, reject) => {
      const stmt = db.prepare('INSERT OR REPLACE INTO system_settings (key, value) VALUES (?, ?)');
      stmt.run('last_backup_date', timestamp, function(err) {
        stmt.finalize();
        if (err) {
          reject(err);
        } else {
          res.json({ message: 'Auto-backup saved successfully', path: cleanBackupPath, timestamp });
          resolve();
        }
      });
    });

  } catch (error) {
    console.error('Auto-backup error:', error);
    res.status(500).json({ error: 'Failed to save auto-backup: ' + error.message });
  }
});

// Get auto-backup data (reads from server file system)
app.get('/api/auto-backup', async (req, res) => {
  try {
    // Get backup path from settings
    const backupPath = await new Promise((resolve, reject) => {
      db.get('SELECT value FROM system_settings WHERE key = ?', ['backup_file_path'], (err, row) => {
        if (err) reject(err);
        else resolve(row ? row.value : '');
      });
    });

    if (!backupPath.trim()) {
      return res.status(400).json({ error: 'No backup file path configured' });
    }

    // Clean path and determine if it's a directory or file
    const cleanBackupPath = backupPath.replace(/["']/g, '');
    const hasFileExtension = path.extname(cleanBackupPath) !== '';
    const endsWithSeparator = cleanBackupPath.endsWith(path.sep) || cleanBackupPath.endsWith('/');

    let targetBackupFile = null;
    let searchDirectory = null;

    if (hasFileExtension) {
      // If path has file extension, it's a specific file
      targetBackupFile = cleanBackupPath;
      searchDirectory = path.dirname(cleanBackupPath);
      console.log('Specific backup file specified:', targetBackupFile);
    } else {
      // If no file extension, treat as directory
      searchDirectory = cleanBackupPath;
      console.log('Searching for backup files in directory:', searchDirectory);
    }

    // Validate the search directory exists and is actually a directory
    try {
      const searchStats = await fs.stat(searchDirectory);
      if (!searchStats.isDirectory()) {
        return res.status(400).json({ error: 'Configured backup location is not a valid directory' });
      }
    } catch (error) {
      return res.status(400).json({ error: `Cannot access backup location: ${searchDirectory} - ${error.message}` });
    }

    let backupData = null;
    let backupFilePath = null;

    if (targetBackupFile) {
      // Use specific file
      backupFilePath = targetBackupFile;
      console.log('Attempting to read specific backup file:', backupFilePath);

      try {
        const fileContent = await fs.readFile(backupFilePath, 'utf8');
        backupData = JSON.parse(fileContent);
        console.log('Successfully loaded backup file:', backupFilePath);
      } catch (error) {
        return res.status(400).json({ error: `Failed to read specified backup file: ${error.message}` });
      }
    } else {
      // Find most recent backup file in directory
      const files = await fs.readdir(searchDirectory);
      const jsonFiles = files
        .filter(file => file.endsWith('.json'))
        .sort(); // Sort alphabetically, which should put timestamped files in order

      console.log('All files in directory:', files);
      console.log('JSON files found:', jsonFiles);

      if (jsonFiles.length === 0) {
        return res.status(404).json({ error: `No backup files found in directory: ${searchDirectory}` });
      }

      // Try files in order, assuming most recent is last in alphabetical sort
      // (timestamped files like "apps-backup-2025-12-07 (7).json" sort after "apps-backup.json")
      for (const file of jsonFiles.reverse()) { // Reverse to check newest first
        try {
          const filePath = path.join(searchDirectory, file);
          const fileContent = await fs.readFile(filePath, 'utf8');
          const parsedData = JSON.parse(fileContent);

          // Validate backup format
          if (!parsedData.apps || !Array.isArray(parsedData.apps)) {
            console.warn(`Skipping backup file ${file}: invalid apps array`);
            continue;
          }

          if (!parsedData.timestamp) {
            console.warn(`Skipping backup file ${file}: missing timestamp`);
            continue;
          }

          // Check if this is more recent than previous valid backup
          if (!backupData ||
              !backupData.timestamp ||
              parsedData.timestamp > backupData.timestamp) {
            backupData = parsedData;
            backupFilePath = filePath;
            console.log(`Found valid backup file: ${file}, timestamp: ${parsedData.timestamp}`);
          }
        } catch (parseError) {
          console.warn(`Skipping invalid backup file ${file}: ${parseError.message}`);
        }
      }
    }

    if (!backupData) {
      return res.status(404).json({ error: 'No valid backup files found in the specified location' });
    }

    // Final validation of backup data
    if (!Array.isArray(backupData.apps)) {
      return res.status(400).json({ error: 'Invalid backup format: apps field must be an array' });
    }

    if (!backupData.timestamp) {
      return res.status(400).json({ error: 'Invalid backup format: timestamp field is required' });
    }

    console.log(`Using backup file: ${backupFilePath}`);
    console.log(`Backup timestamp: ${backupData.timestamp}`);
    console.log(`Number of apps in backup: ${backupData.apps.length}`);

    res.json(backupData);

  } catch (error) {
    console.error('Auto-backup retrieval error:', error);
    res.status(500).json({ error: 'Failed to retrieve auto-backup: ' + error.message });
  }
});

// System settings endpoints
app.get('/api/settings/:key', (req, res) => {
  const { key } = req.params;
  db.get('SELECT value FROM system_settings WHERE key = ?', [key], (err, row) => {
    if (err) {
      res.status(500).json({ error: err.message });
      return;
    }
    res.json({ key, value: row ? row.value : null });
  });
});

app.put('/api/settings/:key', (req, res) => {
  const { key } = req.params;
  const { value } = req.body;
  const stmt = db.prepare('INSERT OR REPLACE INTO system_settings (key, value) VALUES (?, ?)');
  stmt.run(key, value, function(err) {
    if (err) {
      res.status(500).json({ error: err.message });
      return;
    }
    res.json({ key, value });
  });
  stmt.finalize();
});

// Start server
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

process.on('SIGINT', () => {
  db.close((err) => {
    if (err) {
      console.error('Error closing database:', err.message);
    } else {
      console.log('Database connection closed.');
    }
    process.exit(0);
  });
});
