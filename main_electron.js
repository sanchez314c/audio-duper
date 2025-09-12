const { app, BrowserWindow, ipcMain, dialog } = require('electron');
const path = require('path');
const fs = require('fs').promises;
const fpcalc = require('fpcalc');
const mm = require('music-metadata');

let mainWindow;

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 1200,
    height: 800,
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true,
      preload: path.join(__dirname, 'preload_script.js')
    }
  });

  mainWindow.loadFile('html_interface.html');
  
  if (process.argv.includes('--dev')) {
    mainWindow.webContents.openDevTools();
  }
}

app.whenReady().then(createWindow);

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

app.on('activate', () => {
  if (BrowserWindow.getAllWindows().length === 0) {
    createWindow();
  }
});

// Audio processing functions
class AudioDedupe {
  constructor() {
    this.audioExtensions = ['.mp3', '.flac', '.wav', '.m4a', '.aac', '.ogg', '.wma'];
    this.fingerprints = new Map();
    this.duplicateGroups = [];
  }

  async scanDirectory(dirPath, progressCallback) {
    const files = await this.getAllAudioFiles(dirPath);
    const total = files.length;
    let processed = 0;

    for (const file of files) {
      try {
        const fingerprint = await this.getFingerprint(file);
        const metadata = await this.getMetadata(file);
        
        const fileInfo = {
          path: file,
          fingerprint,
          size: (await fs.stat(file)).size,
          bitrate: metadata.format.bitrate || 0,
          duration: metadata.format.duration || 0,
          modified: (await fs.stat(file)).mtime
        };

        if (this.fingerprints.has(fingerprint)) {
          this.fingerprints.get(fingerprint).push(fileInfo);
        } else {
          this.fingerprints.set(fingerprint, [fileInfo]);
        }

        processed++;
        progressCallback({ processed, total, current: file });
      } catch (error) {
        console.warn(`Error processing ${file}:`, error.message);
        processed++;
        progressCallback({ processed, total, current: file, error: error.message });
      }
    }

    this.generateDuplicateGroups();
    return this.duplicateGroups;
  }

  async getAllAudioFiles(dirPath) {
    const files = [];
    
    async function scanRecursive(currentPath) {
      const entries = await fs.readdir(currentPath, { withFileTypes: true });
      
      for (const entry of entries) {
        const fullPath = path.join(currentPath, entry.name);
        
        if (entry.isDirectory()) {
          await scanRecursive(fullPath);
        } else if (entry.isFile()) {
          const ext = path.extname(entry.name).toLowerCase();
          if (this.audioExtensions.includes(ext)) {
            files.push(fullPath);
          }
        }
      }
    }

    await scanRecursive.call(this, dirPath);
    return files;
  }

  async getFingerprint(filePath) {
    return new Promise((resolve, reject) => {
      fpcalc(filePath, { length: 120 }, (err, result) => {
        if (err) reject(err);
        else resolve(result.fingerprint);
      });
    });
  }

  async getMetadata(filePath) {
    try {
      return await mm.parseFile(filePath);
    } catch (error) {
      return { format: {} };
    }
  }

  generateDuplicateGroups() {
    this.duplicateGroups = [];
    
    for (const [fingerprint, files] of this.fingerprints) {
      if (files.length > 1) {
        // Sort by quality (bitrate, then size, then modification date)
        files.sort((a, b) => {
          if (a.bitrate !== b.bitrate) return b.bitrate - a.bitrate;
          if (a.size !== b.size) return b.size - a.size;
          return b.modified - a.modified;
        });

        this.duplicateGroups.push({
          fingerprint,
          original: files[0],
          duplicates: files.slice(1),
          totalSize: files.reduce((sum, f) => sum + f.size, 0),
          wasteSize: files.slice(1).reduce((sum, f) => sum + f.size, 0)
        });
      }
    }

    // Sort groups by waste size (biggest savings first)
    this.duplicateGroups.sort((a, b) => b.wasteSize - a.wasteSize);
  }
}

// IPC handlers
ipcMain.handle('select-folder', async () => {
  const result = await dialog.showOpenDialog(mainWindow, {
    properties: ['openDirectory']
  });
  
  return result.canceled ? null : result.filePaths[0];
});

ipcMain.handle('scan-directory', async (event, dirPath) => {
  const dedupe = new AudioDedupe();
  
  return new Promise((resolve, reject) => {
    dedupe.scanDirectory(dirPath, (progress) => {
      mainWindow.webContents.send('scan-progress', progress);
    }).then(resolve).catch(reject);
  });
});

ipcMain.handle('delete-files', async (event, filePaths) => {
  const results = [];
  
  for (const filePath of filePaths) {
    try {
      await fs.unlink(filePath);
      results.push({ path: filePath, success: true });
    } catch (error) {
      results.push({ path: filePath, success: false, error: error.message });
    }
  }
  
  return results;
});