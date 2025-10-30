# 🛠️ AudioDUPER Development Guide

This comprehensive guide covers everything you need to know about developing and maintaining AudioDUPER.

## 📋 Table of Contents

- [Prerequisites](#prerequisites)
- [Development Environment Setup](#development-environment-setup)
- [Project Structure](#project-structure)
- [Build System](#build-system)
- [Testing](#testing)
- [Debugging](#debugging)
- [Code Style & Conventions](#code-style--conventions)
- [Development Workflow](#development-workflow)
- [Performance Optimization](#performance-optimization)
- [Architecture Overview](#architecture-overview)
- [Troubleshooting](#troubleshooting)

## 🚀 Prerequisites

### Required Software

- **Node.js** 16+ (recommend 18 LTS)
- **npm** 8+ or **yarn** 1.22+
- **Git** 2.20+

### Platform-Specific Dependencies

#### macOS
```bash
# Install Xcode Command Line Tools
xcode-select --install

# Install chromaprint via Homebrew
brew install chromaprint

# Optional: Install wine for Windows builds
brew install --cask wine-stable
```

#### Windows
- [Visual Studio Build Tools](https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2022)
- [Windows SDK](https://developer.microsoft.com/en-us/windows/downloads/windows-sdk/)
- [chromaprint binaries](https://acoustid.org/chromaprint)

#### Linux
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install build-essential libchromaprint-tools

# Fedora
sudo dnf install @development-tools chromaprint-tools

# Arch Linux
sudo pacman -S base-devel chromaprint
```

## 🏗️ Development Environment Setup

### 1. Clone and Setup

```bash
# Clone the repository
git clone https://github.com/audiodupe/audiodupe.git
cd audiodupe

# Install dependencies
npm install

# Run in development mode
npm run dev
```

### 2. Environment Configuration

Create a `.env.local` file for development settings:

```env
# Development flags
ELECTRON_IS_DEV=1
NODE_ENV=development

# Debug options
DEBUG=*            # Enable all debug logs
DEBUG=audio:*      # Enable only audio-related logs

# Performance monitoring
ELECTRON_ENABLE_LOGGING=1
ELECTRON_ENABLE_STACK_DUMPING=1
```

### 3. IDE Configuration

#### VS Code Setup

Install recommended extensions from `.vscode/extensions.json`:

```bash
code --install-extension ms-vscode.vscode-eslint
code --install-extension esbenp.prettier-vscode
code --install-extension ms-vscode.vscode-electron
```

Configure VS Code settings:

```json
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "eslint.workingDirectories": ["src"],
  "files.exclude": {
    "**/node_modules": true,
    "**/dist": true,
    "**/build-temp": true
  }
}
```

## 📁 Project Structure

```
AudioDUPER/
├── 📁 src/                     # All source code
│   ├── main.js                 # Main Electron process
│   ├── preload.js              # Secure preload script
│   ├── index.html              # Main UI
│   ├── assets/                 # Static assets
│   │   ├── icon.png
│   │   └── icon.icns
│   ├── components/             # UI components (future)
│   ├── services/               # Business logic (future)
│   ├── utils/                  # Utility functions (future)
│   └── styles/                 # CSS/styling (future)
├── 📁 scripts/                 # Build and automation
│   ├── build-compile-dist.sh   # Enhanced build script
│   ├── compile-build-dist-comprehensive.sh
│   ├── bloat-check.sh          # Dependency analysis
│   └── temp-cleanup.sh         # System cleanup
├── 📁 docs/                    # Documentation
│   ├── DEVELOPMENT.md          # This file
│   ├── API_REFERENCE.md        # API documentation
│   ├── ARCHITECTURE.md         # System architecture
│   └── DEPLOYMENT.md           # Deployment guide
├── 📁 build-resources/         # Build assets
│   ├── icons/                  # Application icons
│   └── entitlements.mac.plist  # macOS permissions
├── 📁 tests/                   # Test files
│   ├── unit/                   # Unit tests
│   └── integration/            # Integration tests
├── 📁 .github/                 # GitHub configuration
│   ├── workflows/              # CI/CD pipelines
│   └── PULL_REQUEST_TEMPLATE.md
├── 📄 package.json             # Dependencies and scripts
├── 📄 README.md                # User documentation
├── 📄 LICENSE                  # License information
└── 📄 .gitignore               # Git ignore rules
```

## 🔧 Build System

### Development Commands

```bash
# Start in development mode with hot reload
npm run dev

# Start normally
npm start

# Run tests
npm test

# Run linting
npm run lint

# Format code
npm run format
```

### Build Commands

```bash
# Build for current platform
npm run build

# Build for specific platforms
npm run build:mac
npm run build:win
npm run build:linux

# Create distributables
npm run dist
npm run dist:mac
npm run dist:win
npm run dist:linux

# Build all platforms
npm run dist:all

# Comprehensive build with all variants
npm run dist:maximum

# Custom build with options
./scripts/build-compile-dist.sh --parallel --skip-tests
```

### Build Scripts Overview

- `build-compile-dist.sh`: Enhanced build script with options
- `compile-build-dist-comprehensive.sh`: Full multi-platform build
- `bloat-check.sh`: Analyze dependency sizes
- `temp-cleanup.sh`: Clean temporary files

## 🧪 Testing

### Test Structure

```
tests/
├── unit/                       # Unit tests
│   ├── main.test.js           # Main process tests
│   ├── preload.test.js        # Preload script tests
│   └── utils/                 # Utility function tests
├── integration/               # Integration tests
│   ├── file-operations.test.js
│   └── audio-processing.test.js
└── fixtures/                  # Test data
    ├── audio-samples/
    └── test-configs/
```

### Running Tests

```bash
# Run all tests
npm test

# Run specific test file
npm test -- tests/unit/main.test.js

# Run tests with coverage
npm run test:coverage

# Watch mode for development
npm run test:watch
```

### Writing Tests

```javascript
// Example unit test
const assert = require('assert');

describe('AudioDUPER Main Process', () => {
  it('should initialize correctly', () => {
    // Test main process initialization
  });

  it('should handle file operations', () => {
    // Test file handling logic
  });
});
```

## 🐛 Debugging

### Electron Debugging

#### Main Process Debugging

```bash
# Start with Node.js inspector
npm run dev -- --inspect=9229

# Connect Chrome DevTools
# Navigate to chrome://inspect and click "Open dedicated DevTools"
```

#### Renderer Process Debugging

```javascript
// In main.js
mainWindow.webContents.openDevTools();

// Or conditionally for development
if (process.env.ELECTRON_IS_DEV) {
  mainWindow.webContents.openDevTools();
}
```

### Debugging Tools

1. **Chrome DevTools**: For renderer process debugging
2. **Node.js Inspector**: For main process debugging
3. **VS Code Debugger**: Integrated debugging experience

### Common Debugging Scenarios

```javascript
// Logging with debug module
const debug = require('debug')('audio:main');
debug('Starting application...');

// Performance monitoring
console.time('audio-processing');
// ... audio processing code ...
console.timeEnd('audio-processing');

// Memory usage tracking
setInterval(() => {
  const usage = process.memoryUsage();
  console.log('Memory:', usage);
}, 5000);
```

## 📝 Code Style & Conventions

### JavaScript Conventions

- Use ES6+ features when appropriate
- Prefer `const` over `let` when possible
- Use async/await instead of callbacks
- Follow JSDoc documentation standards

```javascript
/**
 * Processes audio files to find duplicates
 * @param {string[]} filePaths - Array of file paths to process
 * @param {Object} options - Processing options
 * @returns {Promise<Object[]>} Array of duplicate groups
 */
async function findDuplicates(filePaths, options = {}) {
  // Implementation
}
```

### File Naming

- Use `kebab-case` for file names
- Use `PascalCase` for classes/components
- Use `camelCase` for variables and functions

### Error Handling

```javascript
// Proper error handling
async function processFile(filePath) {
  try {
    const result = await audioProcessor.analyze(filePath);
    return result;
  } catch (error) {
    console.error(`Failed to process file ${filePath}:`, error);
    throw new Error(`Audio processing failed: ${error.message}`);
  }
}
```

## 🔄 Development Workflow

### 1. Feature Development

```bash
# Create feature branch
git checkout -b feature/audio-enhancement

# Make changes
# ... implement feature ...

# Run tests and linting
npm test
npm run lint

# Build and test
npm run build

# Commit and push
git add .
git commit -m "feat: add audio enhancement feature"
git push origin feature/audio-enhancement
```

### 2. Code Review Process

1. Create pull request with descriptive title
2. Fill out PR template completely
3. Ensure CI passes all checks
4. Request review from team members
5. Address feedback promptly
6. Update documentation as needed

### 3. Release Process

```bash
# Update version
npm version patch  # or minor/major

# Create comprehensive build
npm run dist:maximum

# Generate changelog
npm run changelog

# Create release
git push origin main --tags
```

## ⚡ Performance Optimization

### Memory Management

```javascript
// Clean up resources when window closes
mainWindow.on('closed', () => {
  // Dereference window object
  mainWindow = null;

  // Clear any caches
  audioCache.clear();
});

// Use object pooling for frequent allocations
class AudioBufferPool {
  constructor(size = 10) {
    this.pool = [];
    for (let i = 0; i < size; i++) {
      this.pool.push(new AudioBuffer());
    }
  }

  acquire() {
    return this.pool.pop() || new AudioBuffer();
  }

  release(buffer) {
    if (this.pool.length < 10) {
      this.pool.push(buffer);
    }
  }
}
```

### CPU Optimization

```javascript
// Use Worker threads for heavy processing
const { Worker } = require('worker_threads');

function processInWorker(data) {
  return new Promise((resolve, reject) => {
    const worker = new Worker('./audio-worker.js', { workerData: data });
    worker.on('message', resolve);
    worker.on('error', reject);
  });
}
```

### Disk I/O Optimization

```javascript
// Stream large files instead of loading all into memory
const fs = require('fs');
const stream = fs.createReadStream(largeFile);

stream.on('data', (chunk) => {
  // Process chunk incrementally
});
```

## 🏛️ Architecture Overview

### Main Process (main.js)

- Application lifecycle management
- Window management
- System integration
- File system operations
- Audio processing coordination

### Renderer Process (index.html)

- User interface
- DOM manipulation
- User input handling
- Visual feedback

### Preload Script (preload.js)

- Secure context bridge
- API exposure to renderer
- Security sandbox

### Data Flow

```
User Input → Renderer → IPC → Main Process → Audio Processing → Results → UI Update
```

## 🔧 Troubleshooting

### Common Issues

#### "electron command not found"
```bash
# Install dependencies
npm install

# Or install electron globally (not recommended)
npm install -g electron
```

#### "Module not found" errors
```bash
# Clean install
rm -rf node_modules package-lock.json
npm install
```

#### Build failures
```bash
# Clear electron cache
rm -rf ~/Library/Caches/electron

# Clean build artifacts
npm run clean

# Rebuild
npm run build
```

#### Performance issues
```bash
# Check memory usage
npm run debug:memory

# Profile CPU usage
npm run debug:profile
```

### Debug Commands

```bash
# Verbose logging
DEBUG=* npm start

# Memory debugging
node --inspect src/main.js

# Performance profiling
npm run build -- --profile
```

## 📚 Additional Resources

- [Electron Documentation](https://www.electronjs.org/docs)
- [Node.js Documentation](https://nodejs.org/docs/)
- [Chromaprint API](https://acoustid.org/chromaprint)
- [electron-builder Guide](https://electron.build)

## 🤝 Contributing

Please read [CONTRIBUTING.md](../CONTRIBUTING.md) for detailed contribution guidelines.

### Development Commands Reference

```bash
# Development
npm run dev              # Start with debugging
npm start               # Start normally
npm run lint            # Run linter
npm run test            # Run tests
npm run test:watch      # Watch mode testing

# Building
npm run build           # Build for current platform
npm run build:all       # Build all platforms
npm run dist            # Create distributables
npm run dist:maximum    # Build all variants

# Utilities
npm run bloat-check     # Analyze dependencies
npm run temp-clean      # Clean temp files
npm run clean           # Clean build artifacts
npm run clean:deep      # Deep clean including node_modules
```

---

**Happy coding! 🎵**

For questions or support, please open an issue or discussion on GitHub.