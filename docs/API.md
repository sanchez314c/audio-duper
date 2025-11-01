# 📡 API Reference

This document provides a comprehensive reference for AudioDUPER's internal APIs, including main process functions, IPC communication, and audio processing APIs.

## Table of Contents

- [Main Process APIs](#main-process-apis)
- [IPC Communication](#ipc-communication)
- [Audio Processing APIs](#audio-processing-apis)
- [File System APIs](#file-system-apis)
- [UI APIs](#ui-apis)
- [Error Handling](#error-handling)

## Main Process APIs

### AudioDedupe Class

The main class for audio duplicate detection and processing.

#### Constructor

```javascript
const audioDedupe = new AudioDedupe();
```

Creates a new AudioDedupe instance with default settings.

#### Methods

##### `analyzeDirectory(dirPath)`

Analyzes a directory to provide statistics before full scanning.

**Parameters:**

- `dirPath` (string) - Path to directory to analyze

**Returns:** `Promise<DirectoryAnalysis>`

```javascript
const analysis = await audioDedupe.analyzeDirectory('/path/to/music');
console.log(analysis.totalFiles); // Number of audio files found
console.log(analysis.formats); // Array of format statistics
```

**DirectoryAnalysis Object:**

```javascript
{
  totalFiles: number,
  totalSize: number,
  formats: Array<{
    extension: string,
    count: number,
    size: number,
    supported: boolean
  }>,
  errors: string[]
}
```

##### `scanDirectory(dirPath, progressCallback)`

Scans a directory for duplicate audio files.

**Parameters:**

- `dirPath` (string) - Path to directory to scan
- `progressCallback` (function) - Callback for progress updates

**Returns:** `Promise<DuplicateGroup[]>`

```javascript
const duplicates = await audioDedupe.scanDirectory(
  '/path/to/music',
  progress => {
    console.log(`${progress.percentage}% - ${progress.current}`);
  }
);
```

**Progress Object:**

```javascript
{
  processed: number,
  total: number,
  current: string,
  percentage: number,
  error?: string
}
```

**DuplicateGroup Object:**

```javascript
{
  fingerprint: string,
  original: FileInfo,
  duplicates: FileInfo[],
  totalSize: number,
  wasteSize: number,
  formats: string[],
  avgBitrate: number
}
```

**FileInfo Object:**

```javascript
{
  path: string,
  fingerprint: string,
  size: number,
  bitrate: number,
  duration: number,
  modified: Date,
  format: string
}
```

##### `cancel()`

Cancels an ongoing scan operation.

```javascript
audioDedupe.cancel();
```

## IPC Communication

### Renderer-to-Main IPC Calls

These calls are made from renderer process to main process.

#### `select-folder`

Opens a folder selection dialog.

**Returns:** `Promise<string | null>` - Selected folder path or null if cancelled

```javascript
const folder = await window.electronAPI.selectFolder();
if (folder) {
  console.log('Selected:', folder);
}
```

#### `analyze-directory`

Analyzes a directory for audio file statistics.

**Parameters:**

- `dirPath` (string) - Directory path to analyze

**Returns:** `Promise<DirectoryAnalysis>`

```javascript
const analysis = await window.electronAPI.analyzeDirectory(folderPath);
```

#### `scan-directory`

Initiates a full duplicate scan.

**Parameters:**

- `dirPath` (string) - Directory path to scan

**Returns:** `Promise<DuplicateGroup[]>`

```javascript
const duplicates = await window.electronAPI.scanDirectory(folderPath);
```

#### `delete-files`

Deletes specified files.

**Parameters:**

- `filePaths` (string[]) - Array of file paths to delete

**Returns:** `Promise<DeleteResult[]>`

```javascript
const results = await window.electronAPI.deleteFiles([
  'file1.mp3',
  'file2.mp3',
]);
```

**DeleteResult Object:**

```javascript
{
  path: string,
  success: boolean,
  action?: string,
  error?: string
}
```

#### `move-files`

Moves files to a destination folder.

**Parameters:**

- `filePaths` (string[]) - Files to move
- `destinationFolder` (string) - Target directory

**Returns:** `Promise<MoveResult[]>`

```javascript
const results = await window.electronAPI.moveFiles(
  ['file1.mp3', 'file2.mp3'],
  '/path/to/destination'
);
```

**MoveResult Object:**

```javascript
{
  path: string,
  destinationPath?: string,
  success: boolean,
  action?: string,
  error?: string
}
```

#### `select-destination-folder`

Opens a folder selection dialog for destination.

**Returns:** `Promise<string | null>` - Selected folder path

```javascript
const destination = await window.electronAPI.selectDestinationFolder();
```

#### `get-app-info`

Gets application information.

**Returns:** `Promise<AppInfo>`

```javascript
const appInfo = await window.electronAPI.getAppInfo();
console.log(appInfo.version); // Application version
```

**AppInfo Object:**

```javascript
{
  name: string,
  version: string,
  platform: string,
  arch: string,
  electronVersion: string,
  nodeVersion: string
}
```

### Main-to-Renderer IPC Events

These events are sent from main process to renderer process.

#### `folder-selected`

Sent when a folder is selected via menu.

**Data:** `string` - Selected folder path

```javascript
window.electronAPI.onFolderSelected(folderPath => {
  console.log('Folder selected:', folderPath);
});
```

#### `scan-progress`

Sent during scan operations with progress updates.

**Data:** `Progress` object

```javascript
window.electronAPI.onScanProgress(progress => {
  updateProgressBar(progress.percentage);
  updateStatusText(progress.current);
});
```

#### `app-error`

Sent when an unhandled application error occurs.

**Data:** `ErrorInfo` object

```javascript
window.electronAPI.onAppError(errorInfo => {
  showErrorDialog(errorInfo.message, errorInfo.details);
});
```

**ErrorInfo Object:**

```javascript
{
  message: string,
  details: string
}
```

## Audio Processing APIs

### Audio Fingerprinting

#### `getFingerprint(filePath)`

Generates an acoustic fingerprint for an audio file.

**Parameters:**

- `filePath` (string) - Path to audio file

**Returns:** `Promise<string>` - Audio fingerprint

```javascript
const fingerprint = await audioDedupe.getFingerprint('/path/to/file.mp3');
```

**Error Handling:**

- Falls back to size+duration fingerprint if chromaprint fails
- Ultimate fallback to file size only
- Throws error if all methods fail

### Metadata Extraction

#### `getMetadata(filePath)`

Extracts comprehensive metadata from an audio file.

**Parameters:**

- `filePath` (string) - Path to audio file

**Returns:** `Promise<Metadata>`

```javascript
const metadata = await audioDedupe.getMetadata('/path/to/file.mp3');
console.log(metadata.format.bitrate); // Audio bitrate
console.log.metadata.format.duration; // Duration in seconds
```

**Metadata Object:**

```javascript
{
  format: {
    container: string,
    bitrate: number,
    duration: number,
    size?: number
  },
  common?: {
    title?: string,
    artist?: string,
    album?: string,
    year?: number,
    track?: number
  },
  error?: string
}
```

## File System APIs

### File Discovery

#### `getAllAudioFiles(dirPath, analysisMode = false)`

Recursively discovers all audio files in a directory.

**Parameters:**

- `dirPath` (string) - Directory to search
- `analysisMode` (boolean) - Include all possible audio formats if true

**Returns:** `Promise<string[]>` - Array of file paths

```javascript
const files = await audioDedupe.getAllAudioFiles('/music', false);
// Returns only supported audio formats
```

**Supported Audio Extensions:**

```javascript
const audioExtensions = [
  '.mp3',
  '.flac',
  '.wav',
  '.m4a',
  '.aac',
  '.ogg',
  '.wma',
  '.opus',
  '.m4p',
  '.mp4',
  '.caf',
];
```

### File Operations

#### `validatePath(userPath, allowedBase)`

Validates that a path is safe and within allowed bounds.

**Parameters:**

- `userPath` (string) - User-provided path
- `allowedBase` (string) - Base directory that's allowed

**Returns:** `boolean` - True if path is valid

```javascript
const isValid = validatePath(userInput, allowedDirectory);
if (!isValid) {
  throw new Error('Invalid file path');
}
```

## UI APIs

### Window Management

#### `createWindow()`

Creates main application window.

```javascript
function createWindow() {
  mainWindow = new BrowserWindow({
    width: 1200,
    height: 800,
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true,
      preload: path.join(__dirname, 'preload.js'),
    },
  });
}
```

#### Menu Setup

Application menu is automatically configured with:

- File operations (select folder, quit)
- View options (reload, dev tools, zoom)
- Window management (minimize, close)

### Progress Updates

Progress updates are sent automatically during operations:

```javascript
// In renderer process
window.electronAPI.onScanProgress(progress => {
  // Update UI elements
  document.getElementById('progress-bar').value = progress.percentage;
  document.getElementById('status-text').textContent = progress.current;
});
```

## Error Handling

### Error Types

#### `ScanError`

Thrown during directory scanning operations.

```javascript
try {
  const duplicates = await audioDedupe.scanDirectory(folderPath);
} catch (error) {
  if (error instanceof ScanError) {
    console.error('Scan failed:', error.message);
  }
}
```

#### `FileAccessError`

Thrown when file access fails.

```javascript
try {
  const metadata = await audioDedupe.getMetadata(filePath);
} catch (error) {
  if (error instanceof FileAccessError) {
    console.error('Cannot access file:', error.message);
  }
}
```

### Global Error Handlers

The application includes global error handlers:

```javascript
// Uncaught exceptions
process.on('uncaughtException', error => {
  console.error('Uncaught Exception:', error);
  // Send error to renderer process
  mainWindow.webContents.send('app-error', {
    message: 'An unexpected error occurred',
    details: error.message,
  });
});

// Unhandled promise rejections
process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled Rejection:', reason);
});
```

## Usage Examples

### Complete Scan Workflow

```javascript
// In renderer process
async function scanFolder() {
  try {
    // 1. Select folder
    const folder = await window.electronAPI.selectFolder();
    if (!folder) return;

    // 2. Analyze directory
    const analysis = await window.electronAPI.analyzeDirectory(folder);
    displayAnalysis(analysis);

    // 3. Scan for duplicates
    const duplicates = await window.electronAPI.scanDirectory(folder);
    displayDuplicates(duplicates);
  } catch (error) {
    showError(error.message);
  }
}

// Listen for progress updates
window.electronAPI.onScanProgress(progress => {
  updateProgress(progress.percentage, progress.current);
});
```

### File Management

```javascript
// Delete selected duplicates
async function deleteSelectedDuplicates(selectedFiles) {
  const results = await window.electronAPI.deleteFiles(selectedFiles);

  results.forEach(result => {
    if (result.success) {
      console.log(`Deleted: ${result.path}`);
    } else {
      console.error(`Failed to delete ${result.path}: ${result.error}`);
    }
  });
}

// Move files to organized folder
async function moveToOrganizedFolder(files, destination) {
  const results = await window.electronAPI.moveFiles(files, destination);

  const successful = results.filter(r => r.success);
  const failed = results.filter(r => !r.success);

  console.log(`Moved ${successful.length} files successfully`);
  if (failed.length > 0) {
    console.error(`${failed.length} files failed to move`);
  }
}
```

## Development Notes

### Debug Mode

Enable debug mode by starting with `--dev` flag:

```bash
npm run dev
# or
electron . --dev
```

This opens Developer Tools and enables additional logging.

### Logging

The application uses console.log for debugging. In production, consider implementing a proper logging solution.

### Performance Considerations

- Large libraries (>50,000 files) may require significant memory
- Processing speed scales with CPU core count
- SSD storage provides better performance for file operations
- Network drives work but may be slower

---

_This API reference is current as of AudioDUPER v1.0.0. For the latest information, check the source code or GitHub repository._
