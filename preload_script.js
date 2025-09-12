const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('electronAPI', {
  selectFolder: () => ipcRenderer.invoke('select-folder'),
  scanDirectory: (dirPath) => ipcRenderer.invoke('scan-directory', dirPath),
  deleteFiles: (filePaths) => ipcRenderer.invoke('delete-files', filePaths),
  onScanProgress: (callback) => ipcRenderer.on('scan-progress', callback),
  removeScanProgressListener: (callback) => ipcRenderer.removeListener('scan-progress', callback)
});