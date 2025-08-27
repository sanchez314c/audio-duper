# 🏗️ AudioDUPER Architecture

This document describes the high-level architecture of AudioDUPER, including system components, data flow, and design patterns.

## Overview

AudioDUPER is built using the Electron framework, combining web technologies with native desktop capabilities. The architecture follows a multi-process design with clear separation of concerns between UI, business logic, and system integration.

## System Architecture

### Process Model

```
┌─────────────────────────────────────────────────────────┐
│   Renderer Process (sandboxed, contextIsolation: true)   │
│   src/renderer/index.html                                │
│   - UI Logic, User Input, Progress Display               │
│   - Accesses Node.js only via window.electronAPI         │
└────────────────────────┬────────────────────────────────┘
                         │ contextBridge
┌────────────────────────▼────────────────────────────────┐
│   Preload Script (src/preload/preload.js)                 │
│   - Input validation layer                               │
│   - Exposes window.electronAPI surface                   │
└────────────────────────┬────────────────────────────────┘
               ipcRenderer.invoke / send
┌────────────────────────▼────────────────────────────────┐
│   Main Process (src/main/main.js)                        │
│   - BrowserWindow lifecycle                              │
│   - AudioDedupe class (fingerprinting, metadata, groups) │
│   - Promise semaphore pool (2x CPU cores for parallelism)│
│   - File system ops (scan, delete, move)                 │
│   - fpcalc, music-metadata                               │
└─────────────────────────────────────────────────────────┘
```

### Core Components

#### Main Process (src/main/main.js)

**Responsibilities:**

- Application lifecycle management
- Frameless window creation (transparent, Neo-Noir Glass Monitor theme)
- File system operations (scan, delete, move)
- Audio processing coordination
- IPC communication hub

**Core Class:**

```javascript
class AudioDedupe {
  constructor() {
    this.audioExtensions = ['.mp3', '.flac', '.wav', '.m4a', '.aac', '.ogg', '.wma', '.opus', '.m4p', '.mp4', '.caf'];
    this.fingerprints = new Map();
    this.duplicateGroups = [];
    this.cancelled = false;
  }

  async analyzeDirectory(dirPath)       // Pre-scan stats (formats, file count, size)
  async scanDirectory(dirPath, cb)      // Full fingerprint scan with progress callbacks
  async getAllAudioFiles(dirPath)       // Recursive file discovery with symlink loop prevention
  async getFingerprint(filePath)       // fpcalc fingerprinting with size+duration fallback
  async getMetadata(filePath)          // music-metadata extraction with M4A special handling
  generateDuplicateGroups()            // Group by fingerprint, sort by quality
  cancel()                             // Abort in-progress scan
}
```

**IPC Handlers registered in main process:**

| Channel | Type | Description |
|---------|------|-------------|
| `select-folder` | invoke | Native OS folder dialog |
| `analyze-directory` | invoke | Pre-scan directory stats |
| `scan-directory` | invoke | Full fingerprint scan |
| `cancel-scan` | invoke | Cancel active scan |
| `select-destination-folder` | invoke | Native destination folder dialog |
| `delete-files` | invoke | Delete array of file paths |
| `move-files` | invoke | Move files to destination |
| `get-app-info` | invoke | App name, version, platform, Electron/Node versions |
| `play-audio-file` | invoke | Load audio file as base64 for in-app playback |
| `window-close` | on | Close the frameless window |

**Events emitted to renderer:**

| Event | Description |
|-------|-------------|
| `scan-progress` | `{ processed, total, current, percentage }` |
| `app-error` | `{ message, details }` |

#### Renderer Process (src/renderer/index.html)

**Responsibilities:**

- Single-file UI (inline CSS + JS, Neo-Noir Glass Monitor design system)
- User input handling (folder selection, scan controls)
- Progress display
- Results visualization (duplicate groups with quality comparisons)
- In-app audio playback

#### Preload Script (src/preload/preload.js)

**Responsibilities:**

- Secure context bridge between sandboxed renderer and main process
- Input validation on all IPC calls before they reach main
- Exposes only purpose-specific functions via `contextBridge`

**API exposed as `window.electronAPI`:**

```javascript
contextBridge.exposeInMainWorld('electronAPI', {
  closeWindow: () => ipcRenderer.send('window-close'),
  selectFolder: () => ipcRenderer.invoke('select-folder'),
  analyzeDirectory: dirPath => ipcRenderer.invoke('analyze-directory', dirPath),
  scanDirectory: dirPath => ipcRenderer.invoke('scan-directory', dirPath),
  cancelScan: () => ipcRenderer.invoke('cancel-scan'),
  selectDestinationFolder: () => ipcRenderer.invoke('select-destination-folder'),
  deleteFiles: filePaths => ipcRenderer.invoke('delete-files', filePaths),
  moveFiles: (filePaths, dest) => ipcRenderer.invoke('move-files', filePaths, dest),
  getAppInfo: () => ipcRenderer.invoke('get-app-info'),
  playAudioFile: filePath => ipcRenderer.invoke('play-audio-file', filePath),
  onScanProgress: callback => { ipcRenderer.on('scan-progress', callback); return cleanup; },
  onFolderSelected: callback => { ipcRenderer.on('folder-selected', callback); return cleanup; },
  onAppError: callback => { ipcRenderer.on('app-error', callback); return cleanup; },
  removeAllListeners: () => { /* cleanup all listeners */ },
  utils: { getPlatform, getBasename, formatBytes },
});
```

## Data Flow

### Scan Workflow

```
1. User selects folder
   Renderer → IPC → Main
   ↓
2. Directory analysis
   Main: analyzeDirectory()
   ↓
3. File discovery
   Main: getAllAudioFiles()
   ↓
4. Audio processing
   Main: Promise semaphore pool processes files in parallel
   - Generate fingerprints (fpcalc)
   - Extract metadata (music-metadata)
   ↓
5. Duplicate detection
   Main: Group by fingerprint
   ↓
6. Results transmission
   Main → IPC → Renderer
   ↓
7. Display results
   Renderer: Update UI
```

### File Operations Flow

```
1. User action (delete/move)
   Renderer → IPC → Main
   ↓
2. Validation
   Main: validatePath(), check permissions
   ↓
3. Operation execution
   Main: fs.unlink() or fs.rename()
   ↓
4. Result reporting
   Main → IPC → Renderer
   ↓
5. UI update
   Renderer: Update display
```

## Security Architecture

### Context Isolation

```
┌─────────────────────────────────────────────────────────┐
│                Renderer Process                    │
│  ┌─────────────────────────────────────────────┐   │
│  │            Web Content                 │   │
│  │  - No Node.js access                  │   │
│  │  - Limited file system access          │   │
│  └─────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────┐   │
│  │           Preload Script                │   │
│  │  - Controlled API bridge              │   │
│  │  - Input validation                   │   │
│  │  - Security filtering                  │   │
│  └─────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│                Main Process                      │
│  ┌─────────────────────────────────────────────┐   │
│  │         Node.js Runtime                 │   │
│  │  - Full file system access             │   │
│  │  - System integration                 │   │
│  │  - Audio processing                  │   │
│  └─────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

### Security Measures

1. **Path Validation**

   ```javascript
   function validatePath(userPath, allowedBase) {
     const resolved = path.resolve(userPath);
     const base = path.resolve(allowedBase);
     return resolved.startsWith(base);
   }
   ```

2. **Input Sanitization**

   ```javascript
   // In preload script
   const sanitizeInput = input => {
     return input.replace(/[<>]/g, '');
   };
   ```

3. **Error Information Control**
   ```javascript
   // Don't expose system paths in error messages
   const safeError = error => {
     return error.message.replace(/\/.*\//g, '[path]/');
   };
   ```

## Performance Architecture

### Parallel Processing

All concurrency is implemented via a Promise-based semaphore pool in the main process. No actual Worker threads are used. Concurrency is set to `Math.max(2, os.cpus().length * 2)` — 2x the CPU core count — to maximize I/O throughput.

For each file, three async operations are run simultaneously via `Promise.all`:

```javascript
const [fingerprint, metadata, stats] = await Promise.all([
  this.getFingerprint(file),   // fpcalc acoustic fingerprint
  this.getMetadata(file),      // music-metadata parse
  fs.stat(file),               // file size + mtime
]);
```

The semaphore limits how many files are processed at once, while still allowing the event loop to handle IPC progress messages back to the renderer.

### Memory Management

1. **Resource Cleanup**

   ```javascript
   // Clean up on window close
   mainWindow.on('closed', () => {
     audioDedupe.fingerprints.clear();
     audioDedupe.duplicateGroups = [];
     ipcMain.removeAllListeners();
     mainWindow = null;
   });
   ```

3. **Cancellation Support**
   ```javascript
   class CancellableTask {
     constructor() {
       this.cancelled = false;
     }

     cancel() {
       this.cancelled = true;
     }

     async process(items) {
       for (const item of items) {
         if (this.cancelled) throw new Error('Cancelled');
         await this.processItem(item);
       }
     }
   }
   ```

## Technology Stack

### Core Technologies

| Component         | Technology          | Purpose                    |
| ----------------- | ------------------- | -------------------------- |
| Desktop Framework | Electron 39+        | Cross-platform desktop app |
| Audio Processing  | Chromaprint/fpcalc  | Acoustic fingerprinting    |
| Metadata          | music-metadata 11+  | Audio format parsing       |
| Build System      | electron-builder 26+ | Package and distribution  |
| UI                | HTML5/CSS3/JS       | Neo-Noir Glass Monitor UI  |
| Testing           | Jest 29+            | Unit and integration tests |
| Linting           | ESLint 9, Prettier  | Code quality               |

### Dependencies

```javascript
// package.json (actual)
{
  "dependencies": {
    "fpcalc": "^1.3.0",
    "music-metadata": "^11.9.0"
  },
  "devDependencies": {
    "electron": "^39.0.0",
    "electron-builder": "^26.0.12",
    "jest": "^29.7.0",
    "eslint": "^9.38.0",
    "prettier": "^3.6.2",
    "typescript": "^5.9.3"
  }
}
```

## File Organization

### Source Structure

```
src/
├── main.js              # Thin entry shim → re-exports src/main/main.js
├── main/
│   └── main.js          # Main process: AudioDedupe class, IPC handlers, window creation
├── preload.js           # Thin entry shim → re-exports src/preload/preload.js
├── preload/
│   └── preload.js       # Security bridge: contextBridge.exposeInMainWorld('electronAPI')
├── renderer/
│   ├── index.html       # Single-file UI (inline CSS + JS, Neo-Noir Glass Monitor theme)
│   └── assets/
│       └── logo.png     # 64x64 in-app logo
└── shared/
    └── constants.js     # Shared constants (APP_NAME, APP_VERSION)
```

### Runtime Structure

```
Runtime/
├── Main Process Space
│   ├── AudioDedupe class (scan, fingerprint, metadata, group)
│   ├── Promise semaphore pool (concurrency = 2x CPU cores)
│   └── IPC handlers (select-folder, scan-directory, delete-files, move-files, etc.)
├── Renderer Process Space (sandboxed, no Node.js)
│   ├── DOM elements
│   ├── Event handlers
│   ├── Scan progress display
│   └── Duplicate group results
└── Preload Bridge
    ├── Input validation
    └── window.electronAPI surface
```

## Error Handling Architecture

### Error Propagation

```
Main Process (try/catch) → IPC response → Renderer Process
     ↓                        ↓                ↓
  console.error           error field       UI notification
```

## Extension Points

### Adding New Audio Formats

1. **Update File Recognition**

   ```javascript
   // In FileManager
   static audioExtensions = [
     '.mp3', '.flac', '.wav', '.m4a',
     '.new-format'  // Add here
   ];
   ```

2. **Add Metadata Parser**

   ```javascript
   // In audio processor
   async function parseNewFormat(filePath) {
     // Implementation
   }
   ```

3. **Update Documentation**
   - Add format to supported formats list
   - Update API documentation

### Adding New Operations

1. **Define IPC Handler**

   ```javascript
   // In main.js
   ipcMain.handle('new-operation', async (event, data) => {
     // Implementation
   });
   ```

2. **Expose to Renderer**

   ```javascript
   // In preload.js
   contextBridge.exposeInMainWorld('electronAPI', {
     newOperation: data => ipcRenderer.invoke('new-operation', data),
   });
   ```

3. **Implement UI Controller**
   ```javascript
   // In renderer
   async function performNewOperation() {
     const result = await window.electronAPI.newOperation(data);
     // Handle result
   }
   ```

## Future Architecture Considerations

### Potential Enhancements

1. **Fingerprint Caching**
   - Persistent fingerprint cache (SQLite or JSON)
   - Skip re-fingerprinting unchanged files on repeat scans
   - Invalidate cache entries by file mtime/size

2. **Modular Renderer**
   - Extract inline CSS/JS from index.html into separate files
   - Component-based UI architecture
   - Easier theming and maintenance

3. **Worker Thread Investigation**
   - Offload fpcalc spawning and metadata parsing to worker threads
   - Keep main process event loop responsive during large scans
   - Benchmark vs current Promise semaphore approach

---

_This architecture document is updated as the application evolves. For the latest information, refer to the source code._
