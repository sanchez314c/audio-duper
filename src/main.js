const { app, BrowserWindow, ipcMain, dialog, Menu, shell } = require('electron');
const path = require('path');
const fs = require('fs').promises;
const crypto = require('crypto');
const os = require('os');
const fpcalc = require('fpcalc');
const mm = require('music-metadata');
const { Worker } = require('worker_threads');

let mainWindow;
let isScanning = false;

// Enhanced window creation with better security and UX
function createWindow() {
  mainWindow = new BrowserWindow({
    width: 1400,
    height: 900,
    minWidth: 800,
    minHeight: 600,
    show: false, // Don't show until ready
    icon: path.join(__dirname, 'assets', 'icon.png'), // Custom AudioDUPER icon
    titleBarStyle: process.platform === 'darwin' ? 'hiddenInset' : 'default',
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true,
      enableRemoteModule: false,
      preload: path.join(__dirname, 'preload_script.js'),
      sandbox: false // Needed for file operations
    }
  });

  // Load the main interface
  mainWindow.loadFile('index.html');
  
  // Show window when ready to prevent visual flash
  mainWindow.once('ready-to-show', () => {
    mainWindow.show();
    
    // Focus on window
    if (process.platform === 'darwin') {
      mainWindow.focus();
    }
  });
  
  // Open dev tools in development
  if (process.env.NODE_ENV === 'development' || process.argv.includes('--dev')) {
    mainWindow.webContents.openDevTools();
  }

  // Handle external links
  mainWindow.webContents.setWindowOpenHandler(({ url }) => {
    shell.openExternal(url);
    return { action: 'deny' };
  });

  // Create application menu
  createMenu();
}

// Create application menu
function createMenu() {
  const template = [
    {
      label: 'File',
      submenu: [
        {
          label: 'Select Folder...',
          accelerator: 'CmdOrCtrl+O',
          click: async () => {
            const result = await dialog.showOpenDialog(mainWindow, {
              properties: ['openDirectory'],
              title: 'Select Audio Directory'
            });
            if (!result.canceled && result.filePaths[0]) {
              mainWindow.webContents.send('folder-selected', result.filePaths[0]);
            }
          }
        },
        { type: 'separator' },
        {
          label: 'Quit',
          accelerator: process.platform === 'darwin' ? 'Cmd+Q' : 'Ctrl+Q',
          click: () => {
            app.quit();
          }
        }
      ]
    },
    {
      label: 'View',
      submenu: [
        { role: 'reload' },
        { role: 'forceReload' },
        { role: 'toggleDevTools' },
        { type: 'separator' },
        { role: 'resetZoom' },
        { role: 'zoomIn' },
        { role: 'zoomOut' },
        { type: 'separator' },
        { role: 'togglefullscreen' }
      ]
    },
    {
      label: 'Window',
      submenu: [
        { role: 'minimize' },
        { role: 'close' }
      ]
    }
  ];

  if (process.platform === 'darwin') {
    template.unshift({
      label: app.getName(),
      submenu: [
        { role: 'about' },
        { type: 'separator' },
        { role: 'services' },
        { type: 'separator' },
        { role: 'hide' },
        { role: 'hideOthers' },
        { role: 'unhide' },
        { type: 'separator' },
        { role: 'quit' }
      ]
    });
  }

  const menu = Menu.buildFromTemplate(template);
  Menu.setApplicationMenu(menu);
}

// Enhanced Audio Duplicate Detection Class
class AudioDedupe {
  constructor() {
    this.audioExtensions = ['.mp3', '.flac', '.wav', '.m4a', '.aac', '.ogg', '.wma', '.opus', '.m4p', '.mp4', '.caf'];
    this.fingerprints = new Map();
    this.duplicateGroups = [];
    this.cancelled = false;
    this.stats = {
      totalFiles: 0,
      byExtension: new Map(),
      totalSize: 0,
      errors: []
    };
  }

  // New method to analyze directory before scanning
  async analyzeDirectory(dirPath) {
    try {
      this.stats = {
        totalFiles: 0,
        byExtension: new Map(),
        totalSize: 0,
        errors: []
      };

      const files = await this.getAllAudioFiles(dirPath, true); // true = analysis mode
      
      for (const file of files) {
        try {
          const stats = await fs.stat(file);
          const ext = path.extname(file).toLowerCase();
          
          this.stats.totalFiles++;
          this.stats.totalSize += stats.size;
          
          if (this.stats.byExtension.has(ext)) {
            const current = this.stats.byExtension.get(ext);
            this.stats.byExtension.set(ext, {
              count: current.count + 1,
              size: current.size + stats.size
            });
          } else {
            this.stats.byExtension.set(ext, {
              count: 1,
              size: stats.size
            });
          }
        } catch (error) {
          this.stats.errors.push(`Cannot access ${file}: ${error.message}`);
        }
      }

      return {
        totalFiles: this.stats.totalFiles,
        totalSize: this.stats.totalSize,
        formats: Array.from(this.stats.byExtension.entries()).map(([ext, data]) => ({
          extension: ext,
          count: data.count,
          size: data.size,
          supported: this.audioExtensions.includes(ext)
        })).sort((a, b) => b.count - a.count),
        errors: this.stats.errors
      };
    } catch (error) {
      throw new Error(`Directory analysis failed: ${error.message}`);
    }
  }

  // Cancel ongoing scan
  cancel() {
    this.cancelled = true;
  }

  // Main scan directory method with enhanced error handling
  async scanDirectory(dirPath, progressCallback) {
    try {
      this.cancelled = false;
      this.fingerprints.clear();
      this.duplicateGroups = [];

      // Validate directory exists
      const stats = await fs.stat(dirPath);
      if (!stats.isDirectory()) {
        throw new Error('Selected path is not a directory');
      }

      // Get all audio files
      progressCallback({ processed: 0, total: 1, current: 'Discovering audio files...' });
      const files = await this.getAllAudioFiles(dirPath);
      
      if (files.length === 0) {
        throw new Error('No audio files found in the selected directory');
      }

      const total = files.length;
      let processed = 0;

      // Process files in parallel using ALL available CPU cores for maximum speed
      const maxConcurrency = Math.max(2, os.cpus().length * 2); // Use 2x cores for I/O bound operations
      
      console.log(`🚀 TURBO MODE: Processing with ${maxConcurrency} concurrent operations (ALL ${os.cpus().length} cores + I/O optimization)`);
      
      // Create semaphore for proper concurrency control
      const semaphore = Array(maxConcurrency).fill(null).map(() => Promise.resolve());
      let semaphoreIndex = 0;
      
      // Process ALL files in parallel with controlled concurrency
      const filePromises = files.map(async (file, index) => {
        // Get next available semaphore slot
        const slotIndex = semaphoreIndex;
        semaphoreIndex = (semaphoreIndex + 1) % maxConcurrency;
        
        // Wait for slot to be available
        await semaphore[slotIndex];
        
        // Process file and update semaphore
        semaphore[slotIndex] = (async () => {
          if (this.cancelled) return;
          
          try {
            // Run all I/O operations in parallel for this file
            const [fingerprint, metadata, stats] = await Promise.all([
              this.getFingerprint(file),
              this.getMetadata(file),
              fs.stat(file)
            ]);
            
            const fileInfo = {
              path: file,
              fingerprint,
              size: stats.size,
              bitrate: metadata.format.bitrate || 0,
              duration: metadata.format.duration || 0,
              modified: stats.mtime,
              format: metadata.format.container || path.extname(file).slice(1)
            };

            // Thread-safe fingerprint storage
            if (this.fingerprints.has(fingerprint)) {
              this.fingerprints.get(fingerprint).push(fileInfo);
            } else {
              this.fingerprints.set(fingerprint, [fileInfo]);
            }

            processed++;
            
            // Update progress more frequently for better UX
            if (processed % 10 === 0 || processed === total) {
              progressCallback({ 
                processed, 
                total, 
                current: `Processed: ${path.basename(file)}`,
                percentage: Math.round((processed / total) * 100)
              });
            }
          } catch (error) {
            console.warn(`Error processing ${file}:`, error.message);
            processed++;
            
            if (processed % 10 === 0 || processed === total) {
              progressCallback({ 
                processed, 
                total, 
                current: `Error: ${path.basename(file)}`,
                error: error.message,
                percentage: Math.round((processed / total) * 100)
              });
            }
          }
        })();
        
        return semaphore[slotIndex];
      });
      
      // Wait for all files to complete
      await Promise.allSettled(filePromises);

      this.generateDuplicateGroups();
      return this.duplicateGroups;

    } catch (error) {
      console.error('Scan directory error:', error);
      throw error;
    }
  }

  // Enhanced file discovery with better error handling
  async getAllAudioFiles(dirPath, analysisMode = false) {
    const files = [];
    const visited = new Set(); // Prevent circular references
    
    const scanRecursive = async (currentPath) => {
      try {
        const realPath = await fs.realpath(currentPath);
        if (visited.has(realPath)) {
          return; // Skip circular references
        }
        visited.add(realPath);

        const entries = await fs.readdir(currentPath, { withFileTypes: true });
        
        for (const entry of entries) {
          if (this.cancelled) break;

          const fullPath = path.join(currentPath, entry.name);
          
          // Skip hidden files and system directories
          if (entry.name.startsWith('.')) {
            continue;
          }
          
          if (entry.isDirectory()) {
            // Skip common non-audio directories
            const skipDirs = ['node_modules', '.git', 'System Volume Information', '$RECYCLE.BIN', 'Trash'];
            if (!skipDirs.includes(entry.name)) {
              await scanRecursive(fullPath);
            }
          } else if (entry.isFile()) {
            const ext = path.extname(entry.name).toLowerCase();
            
            if (analysisMode) {
              // In analysis mode, collect ALL audio-like files
              const possibleAudioExts = ['.mp3', '.flac', '.wav', '.m4a', '.aac', '.ogg', '.wma', '.opus', '.m4p', '.mp4', '.caf', '.3gp', '.amr', '.ape', '.wv'];
              if (possibleAudioExts.includes(ext)) {
                files.push(fullPath);
              }
            } else {
              // In scan mode, only collect supported formats
              if (this.audioExtensions.includes(ext)) {
                files.push(fullPath);
              }
            }
          }
        }
      } catch (error) {
        console.warn(`Cannot access directory ${currentPath}:`, error.message);
        if (this.stats) {
          this.stats.errors.push(`Directory access error: ${currentPath}`);
        }
      }
    };

    await scanRecursive(dirPath);
    return files;
  }

  // Enhanced fingerprinting with timeout and fallback methods
  async getFingerprint(filePath) {
    try {
      // Primary method: Use fpcalc for audio fingerprinting
      return await new Promise((resolve, reject) => {
        const timeout = setTimeout(() => {
          reject(new Error('Fingerprint generation timed out'));
        }, 10000); // 10 second timeout for speed

        fpcalc(filePath, { length: 120 }, (err, result) => {
          clearTimeout(timeout);
          if (err) {
            reject(new Error(`Fingerprint error: ${err.message}`));
          } else {
            resolve(result.fingerprint);
          }
        });
      });
    } catch (error) {
      console.warn(`Primary fingerprinting failed for ${filePath}: ${error.message}`);
      
      // Fallback method 1: Use file size + duration (more reliable for audio)
      try {
        const stats = await fs.stat(filePath);
        const metadata = await this.getMetadata(filePath);
        
        // Create fingerprint from size and duration
        const duration = Math.round(metadata.format.duration || 0);
        const size = stats.size;
        const sizeFingerprint = `size_${size}_duration_${duration}`;
        
        console.log(`Using size+duration fingerprint for ${path.basename(filePath)}: ${sizeFingerprint}`);
        return sizeFingerprint;
      } catch (sizeError) {
        // Ultimate fallback: just use file size
        try {
          const stats = await fs.stat(filePath);
          const sizeOnlyFingerprint = `size_only_${stats.size}`;
          console.log(`Using size-only fingerprint for ${path.basename(filePath)}: ${sizeOnlyFingerprint}`);
          return sizeOnlyFingerprint;
        } catch (finalError) {
          throw new Error(`All fingerprinting methods failed: ${error.message}`);
        }
      }
    }
  }

  // Enhanced metadata extraction with better M4A support
  async getMetadata(filePath) {
    try {
      const ext = path.extname(filePath).toLowerCase();
      
      // Special handling for M4A files
      const options = {
        duration: true,
        skipCovers: true, // Skip cover art to speed up processing
        mergeTagHeaders: false,
        includeChapters: false
      };

      // For M4A files, use more lenient parsing
      if (['.m4a', '.mp4', '.m4p'].includes(ext)) {
        options.skipPostHeaders = true;
        options.skipCovers = true;
      }

      const metadata = await mm.parseFile(filePath, options);
      
      // Ensure we have basic format info
      if (!metadata.format) {
        metadata.format = {};
      }
      
      // Set default container if missing
      if (!metadata.format.container) {
        metadata.format.container = ext.slice(1);
      }

      return metadata;
    } catch (error) {
      console.warn(`Metadata error for ${filePath}:`, error.message);
      
      // Try to get basic file info even if metadata fails
      try {
        const stats = await fs.stat(filePath);
        return {
          format: {
            container: path.extname(filePath).slice(1),
            bitrate: 0,
            duration: 0,
            size: stats.size
          },
          error: error.message
        };
      } catch (statError) {
        return { 
          format: {
            container: path.extname(filePath).slice(1),
            bitrate: 0,
            duration: 0
          },
          error: `${error.message} | ${statError.message}`
        };
      }
    }
  }

  // Enhanced duplicate group generation with better sorting
  generateDuplicateGroups() {
    this.duplicateGroups = [];
    
    for (const [fingerprint, files] of this.fingerprints) {
      if (files.length > 1) {
        // Enhanced sorting algorithm
        files.sort((a, b) => {
          // First by bitrate (higher is better)
          if (a.bitrate !== b.bitrate) return b.bitrate - a.bitrate;
          
          // Then by file size (larger usually better quality)
          if (a.size !== b.size) return b.size - a.size;
          
          // Then by format preference (lossless > high quality lossy > low quality lossy)
          const formatPriority = { 'flac': 5, 'wav': 4, 'm4a': 3, 'mp3': 2, 'aac': 1, 'ogg': 1 };
          const aPriority = formatPriority[a.format] || 0;
          const bPriority = formatPriority[b.format] || 0;
          if (aPriority !== bPriority) return bPriority - aPriority;
          
          // Finally by modification date (newer is usually better)
          return b.modified - a.modified;
        });

        this.duplicateGroups.push({
          fingerprint,
          original: files[0],
          duplicates: files.slice(1),
          totalSize: files.reduce((sum, f) => sum + f.size, 0),
          wasteSize: files.slice(1).reduce((sum, f) => sum + f.size, 0),
          formats: [...new Set(files.map(f => f.format))],
          avgBitrate: Math.round(files.reduce((sum, f) => sum + f.bitrate, 0) / files.length)
        });
      }
    }

    // Sort groups by waste size (biggest potential savings first)
    this.duplicateGroups.sort((a, b) => b.wasteSize - a.wasteSize);
  }
}

// App lifecycle management
app.whenReady().then(() => {
  createWindow();
  
  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createWindow();
    }
  });
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

app.on('before-quit', () => {
  // Clean up any ongoing operations
  isScanning = false;
});

// Enhanced IPC handlers with better error handling
ipcMain.handle('select-folder', async () => {
  try {
    const result = await dialog.showOpenDialog(mainWindow, {
      properties: ['openDirectory'],
      title: 'Select Audio Directory',
      buttonLabel: 'Select Folder'
    });
    
    return result.canceled ? null : result.filePaths[0];
  } catch (error) {
    console.error('Select folder error:', error);
    throw new Error('Failed to open folder selection dialog');
  }
});

// New handler for directory analysis
ipcMain.handle('analyze-directory', async (event, dirPath) => {
  try {
    const dedupe = new AudioDedupe();
    return await dedupe.analyzeDirectory(dirPath);
  } catch (error) {
    console.error('Analyze directory error:', error);
    throw error;
  }
});

// Enhanced scan directory handler
let currentScan = null;
ipcMain.handle('scan-directory', async (event, dirPath) => {
  if (isScanning) {
    throw new Error('Another scan is already in progress');
  }

  isScanning = true;
  currentScan = new AudioDedupe();
  
  try {
    const results = await currentScan.scanDirectory(dirPath, (progress) => {
      if (mainWindow && !mainWindow.isDestroyed()) {
        mainWindow.webContents.send('scan-progress', progress);
      }
    });
    
    return results;
  } catch (error) {
    console.error('Scan error:', error);
    throw error;
  } finally {
    isScanning = false;
    currentScan = null;
  }
});

// Cancel scan handler
ipcMain.handle('cancel-scan', async () => {
  if (currentScan) {
    currentScan.cancel();
    isScanning = false;
    return true;
  }
  return false;
});

// Select destination folder handler
ipcMain.handle('select-destination-folder', async () => {
  try {
    const result = await dialog.showOpenDialog(mainWindow, {
      properties: ['openDirectory'],
      title: 'Select Destination Folder',
      buttonLabel: 'Select Folder'
    });
    
    return result.canceled ? null : result.filePaths[0];
  } catch (error) {
    console.error('Select destination folder error:', error);
    throw new Error('Failed to open destination folder selection dialog');
  }
});

// Enhanced delete files handler with better error reporting
ipcMain.handle('delete-files', async (event, filePaths) => {
  const results = [];
  
  // Validate files exist before deletion
  for (const filePath of filePaths) {
    try {
      await fs.access(filePath);
    } catch (error) {
      results.push({ 
        path: filePath, 
        success: false, 
        error: 'File no longer exists' 
      });
      continue;
    }

    try {
      await fs.unlink(filePath);
      results.push({ path: filePath, success: true, action: 'deleted' });
    } catch (error) {
      console.error(`Delete error for ${filePath}:`, error);
      results.push({ 
        path: filePath, 
        success: false, 
        error: error.message || 'Unknown error' 
      });
    }
  }
  
  return results;
});

// New move files handler
ipcMain.handle('move-files', async (event, filePaths, destinationFolder) => {
  const results = [];
  
  // Validate destination folder exists
  try {
    const destStats = await fs.stat(destinationFolder);
    if (!destStats.isDirectory()) {
      throw new Error('Destination is not a directory');
    }
  } catch (error) {
    throw new Error(`Invalid destination folder: ${error.message}`);
  }
  
  // Process each file
  for (const filePath of filePaths) {
    try {
      await fs.access(filePath);
      
      const fileName = path.basename(filePath);
      let destinationPath = path.join(destinationFolder, fileName);
      
      // Handle naming conflicts
      let counter = 1;
      while (true) {
        try {
          await fs.access(destinationPath);
          // File exists, create a new name
          const ext = path.extname(fileName);
          const nameWithoutExt = path.basename(fileName, ext);
          destinationPath = path.join(destinationFolder, `${nameWithoutExt}_${counter}${ext}`);
          counter++;
        } catch {
          // File doesn't exist, we can use this name
          break;
        }
      }
      
      // Move the file
      await fs.rename(filePath, destinationPath);
      results.push({ 
        path: filePath, 
        destinationPath,
        success: true, 
        action: 'moved' 
      });
      
    } catch (error) {
      console.error(`Move error for ${filePath}:`, error);
      results.push({ 
        path: filePath, 
        success: false, 
        error: error.message || 'Unknown error' 
      });
    }
  }
  
  return results;
});

// Get app info handler
ipcMain.handle('get-app-info', () => {
  return {
    name: app.getName(),
    version: app.getVersion(),
    platform: process.platform,
    arch: process.arch,
    electronVersion: process.versions.electron,
    nodeVersion: process.versions.node
  };
});

// Error handling for uncaught exceptions
process.on('uncaughtException', (error) => {
  console.error('Uncaught Exception:', error);
  
  if (mainWindow && !mainWindow.isDestroyed()) {
    mainWindow.webContents.send('app-error', {
      message: 'An unexpected error occurred',
      details: error.message
    });
  }
});

process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled Rejection at:', promise, 'reason:', reason);
});