const path = require('path');
const fs = require('fs').promises;

async function testBackupRead() {
  const backupDir = 'C:\\Users\\rober\\OneDrive\\Documents\\AppSelectorBackup';

  console.log('Testing backup file reading...');
  console.log('Backup directory:', backupDir);

  try {
    // Check if directory exists
    const stat = await fs.stat(backupDir);
    console.log('Directory exists:', stat.isDirectory());

    // List files
    const files = await fs.readdir(backupDir);
    console.log('All files:', files);

    // Find JSON files
    const jsonFiles = files.filter(file => file.endsWith('.json'));
    console.log('JSON files:', jsonFiles);

    // Try to read each backup file
    for (const file of jsonFiles) {
      console.log(`\n--- Reading ${file} ---`);
      try {
        const filePath = path.join(backupDir, file);
        const content = await fs.readFile(filePath, 'utf8');
        console.log('File read successfully');

        const parsed = JSON.parse(content);
        console.log('Parsed successfully');
        console.log('Has timestamp:', !!parsed.timestamp);
        console.log('Has apps array:', Array.isArray(parsed.apps));
        console.log('Apps length:', parsed.apps?.length || 0);
        console.log('Timestamp:', parsed.timestamp);

        // Show first app if available
        if (parsed.apps && parsed.apps.length > 0) {
          console.log('First app example:', JSON.stringify(parsed.apps[0], null, 2));
        }

      } catch (err) {
        console.error(`Error reading/parsing ${file}:`, err.message);
      }
    }

  } catch (error) {
    console.error('Error:', error.message);
  }
}

testBackupRead();
