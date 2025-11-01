# 🏗️ AudioDUPER Architecture

This document describes the high-level architecture of AudioDUPER, including system components, data flow, and design patterns.

## Overview

AudioDUPER is built using the Electron framework, combining web technologies with native desktop capabilities. The architecture follows a multi-process design with clear separation of concerns between UI, business logic, and system integration.

## System Architecture

### Process Model

```
┌─────────────────┐    IPC     ┌─────────────────┐
│   Renderer      │ ◄─────────► │     Main        │
│   Process       │             │    Process      │
│                 │             │                 │
│ - UI Logic      │             │ - File System  │
│ - User Input    │             │ - Audio Proc   │
│ - Display       │             │ - IPC Bridge    │
└─────────────────┘             └─────────────────┘
        ▲                               ▲
        │                               │
        │                               │
        ▼                               ▼
┌─────────────────┐             ┌─────────────────┐
│   Preload      │             │  Worker Threads  │
│   Script        │             │                 │
│                 │             │ - Audio FP      │
│ - Security      │             │ - Parallel Proc │
│ - API Bridge    │             │ - Heavy Tasks   │
└─────────────────┘             └─────────────────┘
```

### Core Components

#### Main Process (src/main.js)

**Responsibilities:**

- Application lifecycle management
- Window creation and management
- File system operations
- Audio processing coordination
- IPC communication hub
- System integration (menus, dialogs)

**Key Classes:**

```javascript
class AudioDedupe {
  // Core duplicate detection logic
  async scanDirectory(dirPath, progressCallback)
  async analyzeDirectory(dirPath)
  cancel()
}

class FileManager {
  // File operations and validation
  static validatePath(userPath, allowedBase)
  static getAllAudioFiles(dirPath)
  static deleteFiles(filePaths)
  static moveFiles(filePaths, destination)
}
```

#### Renderer Process (src/index.html)

**Responsibilities:**

- User interface rendering
- User input handling
- Progress display
- Results visualization
- Error presentation

**Key Functions:**

```javascript
// UI Controllers
function selectFolder() {
  /* Folder selection */
}
function startScan() {
  /* Initiate scan */
}
function displayResults(duplicates) {
  /* Show results */
}
function updateProgress(progress) {
  /* Progress updates */
}
```

#### Preload Script (src/preload.js)

**Responsibilities:**

- Secure context bridge
- API exposure to renderer
- Input validation
- Security sandbox enforcement

**API Bridge:**

```javascript
contextBridge.exposeInMainWorld('electronAPI', {
  selectFolder: () => ipcRenderer.invoke('select-folder'),
  scanDirectory: path => ipcRenderer.invoke('scan-directory', path),
  deleteFiles: files => ipcRenderer.invoke('delete-files', files),
  onScanProgress: callback => ipcRenderer.on('scan-progress', callback),
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
   Main: Worker threads process files
   - Generate fingerprints
   - Extract metadata
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

```
┌─────────────────┐
│   Main Thread   │
│                 │
│ - UI Updates    │
│ - Coordination  │
│ - File I/O      │
└─────────────────┘
        │
        ▼ Spawn workers
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│   Worker 1     │ │   Worker 2     │ │   Worker 3     │
│                 │ │                 │ │                 │
│ - Audio FP      │ │ - Audio FP      │ │ - Audio FP      │
│ - Metadata      │ │ - Metadata      │ │ - Metadata      │
└─────────────────┘ └─────────────────┘ └─────────────────┘
```

### Memory Management

1. **Streaming Processing**

   ```javascript
   // Process files in chunks
   for (const chunk of fileChunks) {
     await processChunk(chunk);
     // Allow garbage collection
     await new Promise(resolve => setImmediate(resolve));
   }
   ```

2. **Resource Cleanup**

   ```javascript
   // Clean up on window close
   mainWindow.on('closed', () => {
     workerThreads.forEach(worker => worker.terminate());
     audioCache.clear();
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

| Component         | Technology       | Purpose                    |
| ----------------- | ---------------- | -------------------------- |
| Desktop Framework | Electron 28+     | Cross-platform desktop app |
| Audio Processing  | Chromaprint      | Acoustic fingerprinting    |
| Metadata          | music-metadata   | Audio format parsing       |
| Build System      | electron-builder | Package and distribution   |
| UI                | HTML5/CSS3/JS    | Modern web standards       |

### Dependencies

```javascript
// package.json core dependencies
{
  "dependencies": {
    "electron": "^28.0.0",
    "music-metadata": "^7.14.0"
  },
  "devDependencies": {
    "electron-builder": "^24.0.0",
    "eslint": "^8.0.0",
    "prettier": "^3.0.0"
  }
}
```

## File Organization

### Source Structure

```
src/
├── main.js              # Main process entry point
├── preload.js           # Security bridge
├── index.html           # UI shell
└── assets/             # Static resources
    ├── icons/          # Application icons
    └── styles/         # CSS files
```

### Runtime Structure

```
Runtime/
├── Main Process Space
│   ├── AudioDedupe class
│   ├── FileManager utilities
│   ├── Worker thread pool
│   └── IPC handlers
├── Renderer Process Space
│   ├── DOM elements
│   ├── Event handlers
│   ├── UI controllers
│   └── Progress displays
└── Worker Thread Space
    ├── Audio fingerprinting
    ├── Metadata extraction
    └── File analysis
```

## Error Handling Architecture

### Error Types

```javascript
// Custom error classes
class ScanError extends Error {
  constructor(message, code) {
    super(message);
    this.name = 'ScanError';
    this.code = code;
  }
}

class FileAccessError extends Error {
  constructor(message, path) {
    super(message);
    this.name = 'FileAccessError';
    this.path = path;
  }
}
```

### Error Propagation

```
Worker Thread → Main Process → Renderer Process
     ↓              ↓              ↓
  Error object  →  IPC message  →  UI notification
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

1. **Plugin Architecture**
   - Modular audio processors
   - Extensible file format support
   - Custom duplicate detection algorithms

2. **Database Integration**
   - Persistent scan results
   - Incremental scanning
   - Historical tracking

3. **Cloud Integration**
   - Optional cloud storage
   - Remote processing
   - Synchronization

4. **WebAssembly**
   - Client-side audio processing
   - Reduced main thread load
   - Better performance

---

_This architecture document is updated as the application evolves. For the latest information, refer to the source code._
