const { contextBridge, ipcRenderer } = require('electron');

// Secure API exposure to renderer process
contextBridge.exposeInMainWorld('electronAPI', {
  // Folder selection
  selectFolder: () => ipcRenderer.invoke('select-folder'),

  // Directory analysis (pre-scan)
  analyzeDirectory: dirPath => {
    if (typeof dirPath !== 'string') {
      throw new Error('Directory path must be a string');
    }
    return ipcRenderer.invoke('analyze-directory', dirPath);
  },

  // Directory scanning
  scanDirectory: dirPath => {
    if (typeof dirPath !== 'string') {
      throw new Error('Directory path must be a string');
    }
    return ipcRenderer.invoke('scan-directory', dirPath);
  },

  // Cancel ongoing scan
  cancelScan: () => ipcRenderer.invoke('cancel-scan'),

  // Destination folder selection
  selectDestinationFolder: () =>
    ipcRenderer.invoke('select-destination-folder'),

  // File deletion with validation
  deleteFiles: filePaths => {
    if (!Array.isArray(filePaths)) {
      throw new Error('File paths must be an array');
    }

    // Validate all paths are strings
    for (const path of filePaths) {
      if (typeof path !== 'string') {
        throw new Error('All file paths must be strings');
      }
    }

    return ipcRenderer.invoke('delete-files', filePaths);
  },

  // File moving with validation
  moveFiles: (filePaths, destinationFolder) => {
    if (!Array.isArray(filePaths)) {
      throw new Error('File paths must be an array');
    }

    if (typeof destinationFolder !== 'string') {
      throw new Error('Destination folder must be a string');
    }

    // Validate all paths are strings
    for (const path of filePaths) {
      if (typeof path !== 'string') {
        throw new Error('All file paths must be strings');
      }
    }

    return ipcRenderer.invoke('move-files', filePaths, destinationFolder);
  },

  // App information
  getAppInfo: () => ipcRenderer.invoke('get-app-info'),

  // Event listeners for scan progress
  onScanProgress: callback => {
    if (typeof callback !== 'function') {
      throw new Error('Callback must be a function');
    }
    ipcRenderer.on('scan-progress', callback);

    // Return cleanup function
    return () => ipcRenderer.removeListener('scan-progress', callback);
  },

  // Event listeners for folder selection from menu
  onFolderSelected: callback => {
    if (typeof callback !== 'function') {
      throw new Error('Callback must be a function');
    }
    ipcRenderer.on('folder-selected', callback);

    // Return cleanup function
    return () => ipcRenderer.removeListener('folder-selected', callback);
  },

  // Event listeners for app errors
  onAppError: callback => {
    if (typeof callback !== 'function') {
      throw new Error('Callback must be a function');
    }
    ipcRenderer.on('app-error', callback);

    // Return cleanup function
    return () => ipcRenderer.removeListener('app-error', callback);
  },

  // Remove all listeners for cleanup
  removeAllListeners: () => {
    ipcRenderer.removeAllListeners('scan-progress');
    ipcRenderer.removeAllListeners('folder-selected');
    ipcRenderer.removeAllListeners('app-error');
  },

  // Audio playback functionality
  playAudioFile: async (filePath) => {
    if (typeof filePath !== 'string') {
      throw new Error('File path must be a string');
    }
    return ipcRenderer.invoke('play-audio-file', filePath);
  },

  // Utility functions exposed to renderer
  utils: {
    // Platform detection
    getPlatform: () => process.platform,

    // Path utilities (secure versions)
    getBasename: filepath => {
      if (typeof filepath !== 'string') {
        return '';
      }
      return filepath.split(/[/\\]/).pop() || '';
    },

    // Safe file size formatting
    formatBytes: (bytes, decimals = 2) => {
      if (bytes === 0) {
        return '0 Bytes';
      }

      const k = 1024;
      const dm = decimals < 0 ? 0 : decimals;
      const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB'];

      const i = Math.floor(Math.log(bytes) / Math.log(k));

      return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i];
    },
  },
});

// Expose version information
contextBridge.exposeInMainWorld('appVersion', {
  electron: process.versions.electron,
  chrome: process.versions.chrome,
  node: process.versions.node,
  platform: process.platform,
  arch: process.arch,
});

// Security: Remove Node.js globals from renderer context
delete window.process;
delete window.Buffer;
delete window.global;
