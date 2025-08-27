# Development Guide

This guide covers all aspects of AudioDUPER development, from setup to deployment. It's designed for developers who want to contribute to or extend the AudioDUPER application.

## 🛠️ Development Environment Setup

### Prerequisites

#### Required Software

- **Node.js** 18+ (see `.nvmrc` for exact version)
- **npm** 8+
- **Git** 2.30+
- **Electron** 39+ (installed via npm as devDependency)

#### Platform-Specific Requirements

**macOS**

- Xcode Command Line Tools
- macOS 10.15+ (Catalina or later)
- Apple Developer account for distribution

**Windows**

- Visual Studio Build Tools 2019+
- Windows 10/11
- Windows SDK

**Linux**

- Build-essential tools
- libasound2-dev
- libgtk-3-dev
- libgconf-2-4

### Quick Setup

```bash
# Clone repository
git clone https://github.com/sanchez314c/audio-duper.git
cd audio-duper

# Install dependencies
npm install

# Run development mode
npm run dev

# Run tests
npm test

# Build application
npm run build
```

## 🏗️ Project Architecture

### Directory Structure

```
audio-duper/
├── src/
│   ├── main.js            # Entry shim → src/main/main.js
│   ├── main/
│   │   └── main.js        # Main process: AudioDedupe, IPC handlers, window creation
│   ├── preload.js         # Entry shim → src/preload/preload.js
│   ├── preload/
│   │   └── preload.js     # Security bridge: contextBridge.exposeInMainWorld
│   ├── renderer/
│   │   ├── index.html     # Single-file UI (inline CSS + JS)
│   │   └── assets/        # In-app assets (logo.png)
│   └── shared/
│       └── constants.js   # APP_NAME, APP_VERSION
├── resources/icons/       # App icons (all sizes, all platforms)
├── scripts/               # Build scripts (build-universal.sh, generate-icons.sh)
├── docs/                  # Documentation
├── dev/                   # Internal dev notes (not public docs)
├── tests/                 # Jest test files
├── archive/               # Timestamped backups
└── dist/                  # Build output (generated, gitignored)
```

### Core Components

#### Main Process (src/main/main.js)

- Application lifecycle management
- Frameless window creation (transparent, Neo-Noir Glass Monitor theme)
- File system operations (scan, delete, move with naming conflict resolution)
- AudioDedupe class: fingerprinting, metadata, duplicate grouping
- Promise semaphore for parallel I/O (2x CPU core count)
- IPC communication handling

#### Renderer Process (src/renderer/index.html)

- Single-file UI with inline CSS and JavaScript
- Neo-Noir Glass Monitor design system
- Scan progress and duplicate group visualization
- In-app audio playback

#### Preload Script (src/preload/preload.js)

- Security boundary between main and renderer
- Exposes `window.electronAPI` via `contextBridge.exposeInMainWorld`
- Input validation on all IPC calls (type checks, array validation)
- Removes Node.js globals (`process`, `Buffer`, `global`) from renderer context

### Data Flow

```mermaid
graph TD
    A[User Input] --> B[Renderer Process]
    B --> C[Preload Script]
    C --> D[Main Process]
    D --> E[File System]
    D --> F[Audio Processing]
    F --> G[Chromaprint/fpcalc]
    G --> H[Fingerprint Data]
    H --> I[Duplicate Detection]
    I --> J[Results Display]
    J --> B
```

## 🔧 Development Workflow

### Daily Development

#### Starting Development

```bash
# Start with hot reload
npm run dev

# Start with debugging
npm run dev:debug

# Start with verbose logging
DEBUG=* npm start
```

#### Making Changes

1. **Create Feature Branch**

   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make Changes**
   - Edit source files in `src/`
   - Update tests in `tests/`
   - Update documentation if needed

3. **Test Changes**

   ```bash
   npm test
   npm run lint
   npm run build
   ```

4. **Commit Changes**
   ```bash
   git add .
   git commit -m "feat: add your feature description"
   git push origin feature/your-feature-name
   ```

### Code Standards

#### JavaScript Guidelines

- Use modern ES6+ features
- Implement proper error handling
- Use async/await for asynchronous operations
- Follow ESLint configuration
- Add JSDoc comments for functions

#### Example Code Structure

```javascript
/**
 * Processes audio files and generates fingerprints
 * @param {string[]} filePaths - Array of file paths to process
 * @param {Object} options - Processing options
 * @returns {Promise<Object[]>} Array of processed file data
 */
async function processAudioFiles(filePaths, options = {}) {
  const results = [];

  for (const filePath of filePaths) {
    try {
      const metadata = await getAudioMetadata(filePath);
      const fingerprint = await generateFingerprint(filePath);

      results.push({
        path: filePath,
        metadata,
        fingerprint,
        processedAt: new Date().toISOString(),
      });
    } catch (error) {
      console.error(`Failed to process ${filePath}:`, error);
      results.push({
        path: filePath,
        error: error.message,
        processedAt: new Date().toISOString(),
      });
    }
  }

  return results;
}
```

## 🧪 Testing

### Test Structure

#### Unit Tests

```javascript
// tests/unit/audio.test.js
describe('Audio Processing', () => {
  test('should extract metadata from MP3 file', async () => {
    const testFile = 'tests/fixtures/sample.mp3';
    const metadata = await getAudioMetadata(testFile);

    expect(metadata).toHaveProperty('title');
    expect(metadata).toHaveProperty('artist');
    expect(metadata).toHaveProperty('duration');
  });
});
```

#### Integration Tests

```javascript
// tests/integration/file-ops.test.js
describe('File Operations', () => {
  test('should scan directory for audio files', async () => {
    const testDir = 'tests/fixtures/audio-files';
    const files = await scanForAudioFiles(testDir);

    expect(files.length).toBeGreaterThan(0);
    expect(files.every(file => isAudioFile(file))).toBe(true);
  });
});
```

### Running Tests

```bash
# Run all tests
npm test

# Run tests with coverage
npm run test:coverage

# Run specific test file
npm test -- audio.test.js

# Run tests in watch mode
npm run test:watch

# Run tests with verbose output
npm test -- --verbose
```

### Test Coverage

Target coverage levels:

- **Statements**: 90%+
- **Branches**: 85%+
- **Functions**: 90%+
- **Lines**: 90%+

## 🔌 Audio Processing

### Supported Formats

| Format  | Extension  | Priority | Notes              |
| ------- | ---------- | -------- | ------------------ |
| MP3     | .mp3       | High     | Most common format |
| FLAC    | .flac      | High     | Lossless quality   |
| WAV     | .wav       | Medium   | Uncompressed       |
| M4A/AAC | .m4a, .aac | Medium   | Apple format       |
| OGG     | .ogg       | Medium   | Open source        |
| Opus    | .opus      | Low      | Modern format      |
| WMA     | .wma       | Low      | Windows format     |

### Fingerprint Generation

#### Using fpcalc

```javascript
const { exec } = require('child_process');
const util = require('util');
const execPromise = util.promisify(exec);

async function generateFingerprint(filePath) {
  try {
    const { stdout } = await execPromise(`fpcalc -json "${filePath}"`);
    const result = JSON.parse(stdout);
    return result.fingerprint;
  } catch (error) {
    throw new Error(`Failed to generate fingerprint: ${error.message}`);
  }
}
```

#### Quality Assessment

```javascript
function assessQuality(metadata) {
  let score = 0;

  // Bitrate scoring
  if (metadata.bitrate) {
    if (metadata.bitrate >= 320) score += 4;
    else if (metadata.bitrate >= 256) score += 3;
    else if (metadata.bitrate >= 192) score += 2;
    else if (metadata.bitrate >= 128) score += 1;
  }

  // Format preference
  const formatScores = {
    flac: 5,
    wav: 4,
    mp3: 3,
    m4a: 2,
    ogg: 1,
  };
  score += formatScores[metadata.format?.toLowerCase()] || 0;

  return score;
}
```

## 🎨 User Interface Development

### UI Components

#### Main Window Structure

```html
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8" />
    <title>AudioDUPER</title>
    <style>
      /* All CSS is inline — Neo-Noir Glass Monitor theme */
      :root {
        --bg-primary: #0A0A0F;
        --accent-teal: #3DD6D0;
        --text-primary: #E0E0E0;
        --glass-bg: rgba(255, 255, 255, 0.03);
      }
      /* ... full theme styles inline ... */
    </style>
  </head>
  <body>
    <div id="app">
      <header class="title-bar">
        <!-- Frameless window title bar with drag region -->
      </header>

      <main class="content">
        <section id="file-selection">
          <!-- Directory selection interface -->
        </section>

        <section id="progress">
          <!-- Progress indicators -->
        </section>

        <section id="results">
          <!-- Duplicate results display -->
        </section>
      </main>

      <footer class="status-bar">
        <!-- Status information -->
      </footer>
    </div>

    <script>
      // All JS is inline — renderer logic, event handlers, UI updates
      // Accesses main process via window.electronAPI (preload bridge)
    </script>
  </body>
</html>
```

#### CSS Architecture

```css
/* Inline in index.html — Neo-Noir Glass Monitor theme */
:root {
  --bg-primary: #0A0A0F;
  --bg-secondary: #12121A;
  --accent-teal: #3DD6D0;
  --accent-teal-dim: rgba(61, 214, 208, 0.15);
  --danger-color: #FF4757;
  --text-primary: #E0E0E0;
  --text-muted: rgba(255, 255, 255, 0.4);
  --glass-bg: rgba(255, 255, 255, 0.03);
  --glass-border: rgba(255, 255, 255, 0.06);
}

body {
  background-color: var(--bg-primary);
  color: var(--text-primary);
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
  margin: 0;
}

.title-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 16px;
  background: var(--bg-secondary);
  border-bottom: 1px solid var(--glass-border);
  -webkit-app-region: drag;
}
```

### IPC Communication

#### Main to Renderer

```javascript
// In main.js
mainWindow.webContents.send('progress-update', {
  current: processedCount,
  total: totalCount,
  message: `Processing ${fileName}...`,
});

// In renderer.js
ipcRenderer.on('progress-update', (event, data) => {
  updateProgressBar(data.current, data.total);
  updateStatusMessage(data.message);
});
```

#### Renderer to Main

```javascript
// In preload.js
contextBridge.exposeInMainWorld('electronAPI', {
  selectDirectory: () => ipcRenderer.invoke('select-directory'),
  scanFiles: dirPath => ipcRenderer.invoke('scan-files', dirPath),
  deleteFiles: filePaths => ipcRenderer.invoke('delete-files', filePaths),
});

// In renderer.js
const files = await window.electronAPI.scanFiles(directoryPath);
```

## 🔒 Security Considerations

### Input Validation

#### File Path Validation

```javascript
function validateFilePath(userPath) {
  // Prevent directory traversal
  if (userPath.includes('..')) {
    throw new Error('Invalid file path');
  }

  // Resolve to absolute path
  const resolvedPath = path.resolve(userPath);

  // Ensure within allowed directories
  if (!resolvedPath.startsWith(allowedBasePath)) {
    throw new Error('Access denied');
  }

  return resolvedPath;
}
```

#### File Type Validation

```javascript
function isAudioFile(filePath) {
  const audioExtensions = [
    '.mp3',
    '.flac',
    '.wav',
    '.m4a',
    '.aac',
    '.ogg',
    '.opus',
    '.wma',
  ];

  const ext = path.extname(filePath).toLowerCase();
  return audioExtensions.includes(ext);
}
```

### Secure IPC

#### Preload Script Security

```javascript
const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('electronAPI', {
  // Only expose safe, validated operations
  selectDirectory: () => ipcRenderer.invoke('select-directory'),

  // Validate inputs before sending
  scanFiles: dirPath => {
    if (typeof dirPath !== 'string' || !dirPath.trim()) {
      throw new Error('Invalid directory path');
    }
    return ipcRenderer.invoke('scan-files', dirPath);
  },
});
```

## 📦 Build System

### Build Configuration

#### package.json Build Scripts

```json
{
  "scripts": {
    "build": "electron-builder",
    "build:mac": "electron-builder --mac",
    "build:win": "electron-builder --win",
    "build:linux": "electron-builder --linux",
    "dist:all": "electron-builder -mwl",
    "dist:current": "electron-builder --publish=never"
  }
}
```

#### Build Configuration

```json
{
  "build": {
    "appId": "com.audiodedupe.app",
    "productName": "AudioDUPER",
    "files": [
      "src/main.js",
      "src/preload.js",
      "src/index.html",
      "package.json"
    ],
    "directories": {
      "output": "dist",
      "buildResources": "build-resources"
    },
    "mac": {
      "category": "public.app-category.utilities",
      "target": [
        {
          "target": "dmg",
          "arch": ["x64", "arm64"]
        }
      ]
    },
    "win": {
      "target": [
        {
          "target": "nsis",
          "arch": ["x64"]
        }
      ]
    },
    "linux": {
      "target": [
        {
          "target": "AppImage",
          "arch": ["x64"]
        }
      ]
    }
  }
}
```

### Build Scripts

#### Enhanced Build Script

```bash
#!/bin/bash
# scripts/build-universal.sh

set -e

echo "Starting AudioDUPER build process..."

# Clean previous builds
rm -rf dist/ build/

# Install dependencies
npm ci

# Run tests
npm test

# Build and distribute for current platform
npm run dist:current

echo "Build completed successfully!"
```

## 🐛 Debugging

### Main Process Debugging

#### Chrome DevTools

```javascript
// In main.js
mainWindow.webContents.openDevTools();

// Or conditionally
if (process.env.NODE_ENV === 'development') {
  mainWindow.webContents.openDevTools();
}
```

#### VS Code Debugging

```json
// .vscode/launch.json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Debug Main Process",
      "type": "node",
      "request": "launch",
      "program": "${workspaceFolder}/src/main.js",
      "env": {
        "NODE_ENV": "development"
      },
      "console": "integratedTerminal"
    }
  ]
}
```

### Renderer Process Debugging

#### Remote Debugging

```bash
# Start with remote debugging
npm run dev:debug

# Connect Chrome DevTools
# Navigate to chrome://inspect
# Click "inspect" for the target process
```

### Common Issues

#### Memory Leaks

```javascript
// Proper cleanup
function cleanup() {
  if (fileWatcher) {
    fileWatcher.close();
  }
  if (processingTimer) {
    clearInterval(processingTimer);
  }
}

// Handle app exit
app.on('before-quit', cleanup);
```

#### File Handle Leaks

```javascript
// Always close file handles
async function processFile(filePath) {
  let fileHandle;
  try {
    fileHandle = await fs.open(filePath, 'r');
    // Process file
  } finally {
    if (fileHandle) {
      await fileHandle.close();
    }
  }
}
```

## 📊 Performance Optimization

### Memory Management

#### Streaming Large Files

```javascript
const fs = require('fs');
const stream = fs.createReadStream(largeFile);

stream.on('data', chunk => {
  // Process chunk
});

stream.on('end', () => {
  // File processing complete
});
```

#### Promise Semaphore Pool

```javascript
// Limit concurrent file processing to 2x CPU cores
const concurrency = Math.max(2, os.cpus().length * 2);
let active = 0;

async function processWithSemaphore(file, processFn) {
  while (active >= concurrency) {
    await new Promise(resolve => setTimeout(resolve, 10));
  }
  active++;
  try {
    return await processFn(file);
  } finally {
    active--;
  }
}

// Process all files with controlled parallelism
const results = await Promise.all(
  files.map(file => processWithSemaphore(file, async f => {
    const [fingerprint, metadata, stats] = await Promise.all([
      getFingerprint(f),
      getMetadata(f),
      fs.stat(f),
    ]);
    return { path: f, fingerprint, metadata, stats };
  }))
);
```

### Processing Optimization

#### Batch Processing

```javascript
async function processBatch(files, batchSize = 10) {
  const results = [];

  for (let i = 0; i < files.length; i += batchSize) {
    const batch = files.slice(i, i + batchSize);
    const batchResults = await Promise.all(
      batch.map(file => processFile(file))
    );
    results.push(...batchResults);

    // Report progress
    reportProgress(i + batchSize, files.length);
  }

  return results;
}
```

#### Caching Results

```javascript
const cache = new Map();

async function getCachedFingerprint(filePath) {
  const stats = await fs.stat(filePath);
  const cacheKey = `${filePath}:${stats.mtime.getTime()}`;

  if (cache.has(cacheKey)) {
    return cache.get(cacheKey);
  }

  const fingerprint = await generateFingerprint(filePath);
  cache.set(cacheKey, fingerprint);

  return fingerprint;
}
```

## 🚀 Deployment

### Pre-Deployment Checklist

- [ ] All tests passing
- [ ] Code coverage targets met
- [ ] Security scan clean
- [ ] Documentation updated
- [ ] Version number updated
- [ ] CHANGELOG.md updated
- [ ] Build tested on all platforms

### Release Process

```bash
# 1. Update version
npm version patch  # or minor/major

# 2. Update changelog
# Edit CHANGELOG.md

# 3. Create release
npm run dist:all

# 4. Upload to GitHub Releases
gh release create v1.2.3 dist/* --title "Release v1.2.3"

# 5. Deploy to package managers (if applicable)
npm publish
```

### Automated Deployment

#### GitHub Actions

```yaml
# .github/workflows/release.yml
name: Release

on:
  push:
    tags:
      - 'v*'

jobs:
  release:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [macos-latest, windows-latest, ubuntu-latest]

    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'

      - run: npm ci
      - run: npm test
      - run: npm run build

      - name: Upload artifacts
        uses: actions/upload-artifact@v3
        with:
          name: dist-${{ matrix.os }}
          path: dist/
```

## 📚 Resources

### Documentation

- [Electron Documentation](https://www.electronjs.org/docs)
- [Node.js Documentation](https://nodejs.org/docs/)
- [Chromaprint Documentation](https://acoustid.org/chromaprint)
- [fpcalc Manual](https://acoustid.org/fpcalc)

### Tools and Libraries

- **Electron Builder**: Application packaging
- **Jest**: Testing framework
- **ESLint**: Code linting
- **Prettier**: Code formatting
- **music-metadata**: Audio metadata extraction

### Community

- [Electron Community](https://www.electronjs.org/community)
- [GitHub Discussions](https://github.com/electron/electron/discussions)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/electron)

---

This development guide provides full reference information for AudioDUPER development. For specific questions or issues, refer to the project documentation or create an issue on GitHub.
