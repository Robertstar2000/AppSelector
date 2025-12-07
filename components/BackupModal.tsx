import React, { useState, useEffect } from 'react';
import { X, Save, Upload, Download } from 'lucide-react';
import axios from 'axios';

interface BackupModalProps {
  isOpen: boolean;
  onClose: () => void;
}

const BackupModal: React.FC<BackupModalProps> = ({ isOpen, onClose }) => {
  const [autoBackup, setAutoBackup] = useState(false);
  const [backupFilePath, setBackupFilePath] = useState('');
  const [lastBackup, setLastBackup] = useState<string | null>(null);
  const [apps, setApps] = useState<any[]>([]);
  const [loading, setLoading] = useState(false);

  // Load settings and apps on open
  useEffect(() => {
    if (isOpen) {
      loadSettings();
      loadApps();
    }
  }, [isOpen]);

  const loadSettings = async () => {
    try {
      const [autoBackupRes, filePathRes, lastBackupRes] = await Promise.all([
        axios.get('http://localhost:3001/api/settings/auto_backup'),
        axios.get('http://localhost:3001/api/settings/backup_file_path'),
        axios.get('http://localhost:3001/api/settings/last_backup_date')
      ]);

      setAutoBackup(autoBackupRes.data.value === 'true');
      setBackupFilePath(filePathRes.data.value || '');
      setLastBackup(lastBackupRes.data.value);
    } catch (error) {
      console.error('Error loading settings:', error);
    }
  };

  const loadApps = async () => {
    try {
      const response = await axios.get('http://localhost:3001/api/apps');
      setApps(response.data);
    } catch (error) {
      console.error('Error loading apps:', error);
    }
  };

  const saveSettings = async () => {
    try {
      await axios.put('http://localhost:3001/api/settings/auto_backup', { value: autoBackup.toString() });
      await axios.put('http://localhost:3001/api/settings/backup_file_path', { value: backupFilePath });
    } catch (error) {
      console.error('Error saving settings:', error);
    }
  };

  const handleDownloadBackup = async () => {
    setLoading(true);
    try {
      // Update last backup date
      const timestamp = new Date().toISOString();
      await axios.put('http://localhost:3001/api/settings/last_backup_date', { value: timestamp });

      // Get fresh apps data from server to ensure all recently added/edited apps are included
      const freshAppsResponse = await axios.get('http://localhost:3001/api/apps');
      const freshApps = freshAppsResponse.data;

      // Update local state
      setApps(freshApps);

      // Create backup data with fresh data
      const backupData = {
        timestamp,
        apps: freshApps,
        settings: { autoBackup, backupFilePath }
      };

      // Download file
      const blob = new Blob([JSON.stringify(backupData, null, 2)], { type: 'application/json' });
      const url = URL.createObjectURL(blob);
      const link = document.createElement('a');
      link.href = url;
      link.download = `apps-backup-${new Date().toISOString().split('T')[0]}.json`;
      link.click();
      URL.revokeObjectURL(url);

      // Save to configured backup path
      if (backupFilePath) {
        const backupKey = `backup_${backupFilePath.replace(/[/\\]/g, '_').replace(/[^\w]/g, '')}`;
        localStorage.setItem(backupKey, JSON.stringify(backupData));
      }

      setLastBackup(timestamp);
      await saveSettings();
      alert('Backup downloaded successfully!');
    } catch (error) {
      console.error('Error creating backup:', error);
      alert('Error creating backup');
    } finally {
      setLoading(false);
    }
  };

  const handleRestoreBackup = async () => {
    if (!confirm('Are you sure you want to restore data? This will replace all current app data.')) {
      return;
    }

    if (!backupFilePath.trim()) {
      alert('No backup file path configured. Please set a backup path in the settings first.');
      return;
    }

    try {
      // Restore from the configured backup path (localStorage key based on path)
      const backupKey = `backup_${backupFilePath.replace(/[/\\]/g, '_').replace(/[^\w]/g, '')}`;
      const backupDataJson = localStorage.getItem(backupKey);

      if (!backupDataJson) {
        alert(`No backup found at the configured path: "${backupFilePath}". Please ensure auto-backup is enabled and data has been saved.`);
        return;
      }

      const backupData = JSON.parse(backupDataJson);

      if (!backupData || !Array.isArray(backupData.apps)) {
        alert('Invalid backup data format. The backup file appears to be corrupted.');
        return;
      }

      // Restore the apps
      await axios.put('http://localhost:3001/api/apps', backupData.apps);

      // Restore settings if available
      if (backupData.settings) {
        setAutoBackup(backupData.settings.autoBackup || false);
        setBackupFilePath(backupData.settings.backupFilePath || '');
        if (backupData.settings.autoBackup !== undefined) {
          await axios.put('http://localhost:3001/api/settings/auto_backup', { value: backupData.settings.autoBackup.toString() });
        }
        if (backupData.settings.backupFilePath) {
          await axios.put('http://localhost:3001/api/settings/backup_file_path', { value: backupData.settings.backupFilePath });
        }
      }

      // Update last backup date
      await axios.put('http://localhost:3001/api/settings/last_backup_date', { value: backupData.timestamp });

      setLastBackup(backupData.timestamp);
      await loadApps(); // Refresh the apps list

      alert('Data restored successfully from backup path! The page will reload.');
      window.location.reload(); // Reload to show restored data
    } catch (error) {
      console.error('Error restoring backup:', error);
      alert('Failed to restore backup. Please check that your backup path is correct and contains valid backup data.');
    }
  };

  const handleSettingsChange = async () => {
    await saveSettings();
    alert('Settings saved!');
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm animate-fade-in">
      <div className="bg-white rounded-2xl shadow-2xl w-full max-w-lg overflow-hidden">
        <div className="flex items-center justify-between px-4 py-3 border-b border-gray-100 bg-gray-50">
          <h2 className="text-lg font-bold text-slate-800">
            Backup & Restore
          </h2>
          <button onClick={onClose} className="p-1 rounded-full hover:bg-gray-200 transition-colors">
            <X className="w-5 h-5 text-gray-500" />
          </button>
        </div>

        <div className="p-6 space-y-6">
          {/* Current Status */}
          <div className="bg-gray-50 rounded-lg p-4">
            <h3 className="font-medium text-gray-900 mb-2">Current Status</h3>
            <div className="text-sm text-gray-600 space-y-1">
              <div>Apps in database: {apps.length}</div>
              <div>Last backup: {lastBackup ? new Date(lastBackup).toLocaleString() : 'Never'}</div>
            </div>
          </div>

          {/* Auto Backup Settings */}
          <div className="space-y-4">
            <h3 className="font-medium text-gray-900">Auto Backup Settings</h3>

            <div className="flex items-center space-x-2">
              <input
                type="checkbox"
                id="autoBackup"
                checked={autoBackup}
                onChange={(e) => setAutoBackup(e.target.checked)}
                className="rounded border-gray-300"
              />
              <label htmlFor="autoBackup" className="text-sm text-gray-700">
                Enable automatic backup on app start
              </label>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Backup File Path {!autoBackup && loading && <span className="text-red-500">*</span>}
              </label>
              <input
                type="text"
                value={backupFilePath}
                onChange={(e) => setBackupFilePath(e.target.value)}
                placeholder="/path/to/backup/folder"
                className={`w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-tallman-blue outline-none ${autoBackup && !backupFilePath.trim() ? 'border-red-300 bg-red-50' : 'border-gray-300'}`}
                required={autoBackup}
              />
              <p className="text-xs text-gray-500 mt-1">
                Required for auto-backup. Full path where backup files are stored.
              </p>
              {autoBackup && !backupFilePath.trim() && (
                <p className="text-xs text-red-600 mt-1">
                  Backup file path is required when auto-backup is enabled.
                </p>
              )}
            </div>

            <button
              onClick={handleSettingsChange}
              className="px-4 py-2 bg-gray-600 text-white rounded-lg hover:bg-gray-700 transition-colors text-sm"
            >
              Save Settings
            </button>
          </div>

          {/* Manual Backup/Restore */}
          <div className="space-y-4 border-t border-gray-200 pt-4">
            <h3 className="font-medium text-gray-900">Manual Backup & Restore</h3>

            <div className="flex gap-3">
              <button
                onClick={handleDownloadBackup}
                disabled={loading}
                className="flex-1 flex items-center justify-center gap-2 px-4 py-2 bg-tallman-blue text-white rounded-lg hover:bg-blue-800 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
              >
                <Download className="w-4 h-4" />
                {loading ? 'Creating...' : 'Download Backup'}
              </button>

              <button
                onClick={handleRestoreBackup}
                className="flex-1 flex items-center justify-center gap-2 px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors"
              >
                <Upload className="w-4 h-4" />
                Restore Data
              </button>
            </div>

            <p className="text-xs text-gray-500">
              Restore will replace all current data. Make sure to backup first!
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default BackupModal;
