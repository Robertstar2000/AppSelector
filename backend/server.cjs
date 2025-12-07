const express = require('express');
const sqlite3 = require('sqlite3').verbose();
const cors = require('cors');
const path = require('path');
const fs = require('fs');

const app = express();
const PORT = process.env.PORT || 3001;

// Middleware
app.use(cors());
app.use(express.json());

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
  db.all('SELECT * FROM apps ORDER BY id', (err, rows) => {
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
  const stmt = db.prepare('INSERT OR REPLACE INTO apps (id, name, description, iconName, url, status, type, sourceCode, backendLocation, author, position) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)');
  stmt.run(id, name, description, iconName, url, status, type, sourceCode, backendLocation, author, position, function(err) {
    if (err) {
      res.status(500).json({ error: err.message });
      return;
    }
    res.json({ id, name, description, iconName, url, status, type, sourceCode, backendLocation, author, position });
  });
  stmt.finalize();
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
  db.all('SELECT * FROM apps ORDER BY id', (err, rows) => {
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
