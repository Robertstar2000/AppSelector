const sqlite3 = require('sqlite3').verbose();
const express = require('express');

module.exports = function registerAppsRoutes(app) {
  const router = express.Router();

  // Initialize database
  const db = new sqlite3.Database('./apps.db', (err) => {
    if (err) {
      console.error('Error opening database:', err.message);
    } else {
      console.log('Connected to SQLite database.');
      // Create apps table if it doesn't exist
      db.run(`CREATE TABLE IF NOT EXISTS apps (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        iconName TEXT,
        url TEXT,
        status TEXT,
        type TEXT,
        sourceCode TEXT,
        backendLocation TEXT,
        author TEXT,
        position INTEGER DEFAULT 0
      )`);

      // Create settings table if it doesn't exist
      db.run(`CREATE TABLE IF NOT EXISTS settings (
        key TEXT PRIMARY KEY,
        value TEXT
      )`);
    }
  });

  router.use(express.json());

  // GET /api/apps - Get all apps
  router.get('/apps', (req, res) => {
    db.all('SELECT * FROM apps ORDER BY position ASC, name ASC', [], (err, rows) => {
      if (err) {
        console.error('Error fetching apps:', err);
        return res.status(500).json({ error: 'Failed to fetch apps' });
      }
      res.json(rows);
    });
  });

  // PUT /api/apps - Bulk update all apps
  router.put('/apps', (req, res) => {
    const apps = req.body;
    if (!Array.isArray(apps)) {
      return res.status(400).json({ error: 'Expected array of apps' });
    }

    // Begin transaction
    db.serialize(() => {
      db.run('BEGIN TRANSACTION');

      // Clear existing apps
      db.run('DELETE FROM apps', [], (err) => {
        if (err) {
          db.run('ROLLBACK');
          return res.status(500).json({ error: 'Failed to clear apps' });
        }

        // Insert all apps
        const stmt = db.prepare(`INSERT INTO apps
          (id, name, description, iconName, url, status, type, sourceCode, backendLocation, author, position)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`);

        let completed = 0;
        apps.forEach((app, index) => {
          stmt.run([
            app.id,
            app.name,
            app.description || '',
            app.iconName || '',
            app.url || '',
            app.status || 'ACTIVE',
            app.type || 'URL',
            app.sourceCode || '',
            app.backendLocation || '',
            app.author || '',
            app.position || index
          ], (err) => {
            if (err) {
              console.error('Error inserting app:', err);
              db.run('ROLLBACK');
              return res.status(500).json({ error: 'Failed to save apps' });
            }
            completed++;
            if (completed === apps.length) {
              db.run('COMMIT', (err) => {
                if (err) {
                  db.run('ROLLBACK');
                  return res.status(500).json({ error: 'Failed to commit transaction' });
                }
                res.json({ message: 'Apps saved successfully' });
              });
            }
          });
        });

        stmt.finalize();
      });
    });
  });

  // POST /api/apps - Create new app
  router.post('/apps', (req, res) => {
    const app = req.body;
    if (!app.id || !app.name) {
      return res.status(400).json({ error: 'App id and name are required' });
    }

    const sql = `INSERT INTO apps
      (id, name, description, iconName, url, status, type, sourceCode, backendLocation, author, position)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`;

    db.run(sql, [
      app.id,
      app.name,
      app.description || '',
      app.iconName || '',
      app.url || '',
      app.status || 'ACTIVE',
      app.type || 'URL',
      app.sourceCode || '',
      app.backendLocation || '',
      app.author || '',
      app.position || 0
    ], function(err) {
      if (err) {
        console.error('Error creating app:', err);
        return res.status(500).json({ error: 'Failed to create app' });
      }
      res.json({ id: app.id, message: 'App created successfully' });
    });
  });

  // PUT /api/apps/:id - Update single app
  router.put('/apps/:id', (req, res) => {
    const id = req.params.id;
    const app = req.body;

    const sql = `UPDATE apps SET
      name = ?, description = ?, iconName = ?, url = ?, status = ?, type = ?,
      sourceCode = ?, backendLocation = ?, author = ?, position = ?
      WHERE id = ?`;

    db.run(sql, [
      app.name,
      app.description || '',
      app.iconName || '',
      app.url || '',
      app.status || 'ACTIVE',
      app.type || 'URL',
      app.sourceCode || '',
      app.backendLocation || '',
      app.author || '',
      app.position || 0,
      id
    ], function(err) {
      if (err) {
        console.error('Error updating app:', err);
        return res.status(500).json({ error: 'Failed to update app' });
      }
      if (this.changes === 0) {
        return res.status(404).json({ error: 'App not found' });
      }
      res.json({ message: 'App updated successfully' });
    });
  });

  // DELETE /api/apps/:id - Delete app
  router.delete('/apps/:id', (req, res) => {
    const id = req.params.id;

    db.run('DELETE FROM apps WHERE id = ?', [id], function(err) {
      if (err) {
        console.error('Error deleting app:', err);
        return res.status(500).json({ error: 'Failed to delete app' });
      }
      if (this.changes === 0) {
        return res.status(404).json({ error: 'App not found' });
      }
      res.json({ message: 'App deleted successfully' });
    });
  });

  // Settings routes
  router.get('/settings/:key', (req, res) => {
    const key = req.params.key;
    db.get('SELECT value FROM settings WHERE key = ?', [key], (err, row) => {
      if (err) {
        console.error('Error fetching setting:', err);
        return res.status(500).json({ error: 'Failed to fetch setting' });
      }
      res.json({ value: row ? row.value : null });
    });
  });

  router.put('/settings/:key', (req, res) => {
    const key = req.params.key;
    const value = req.body.value;

    db.run('INSERT OR REPLACE INTO settings (key, value) VALUES (?, ?)', [key, value], function(err) {
      if (err) {
        console.error('Error saving setting:', err);
        return res.status(500).json({ error: 'Failed to save setting' });
      }
      res.json({ message: 'Setting saved successfully' });
    });
  });

  // Backup routes
  router.post('/auto-backup', (req, res) => {
    // This would handle auto-backup, but for now just log
    console.log('Auto-backup received:', req.body);
    res.json({ message: 'Auto-backup processed' });
  });

  app.use('/api', router);
};
