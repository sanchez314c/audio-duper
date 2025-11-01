# 🤖 AudioDUPER - AI Assistant Development Guide

This guide provides specific instructions for AI assistants (like Claude) working on the AudioDUPER project. It contains project-specific guidance, development commands, and architectural patterns to follow when making changes or improvements.

## 🎯 Project Overview

**AudioDUPER** is a cross-platform Electron application that identifies duplicate audio files using Chromaprint fingerprinting technology. It's written primarily in JavaScript with Node.js backend functionality.

### Core Technologies

- **Electron** 28+ - Cross-platform desktop framework
- **Node.js** 16+ - Backend runtime
- **Chromaprint** - Audio fingerprinting library
- **fpcalc** - Command-line audio fingerprint tool
- **music-metadata** - Audio metadata extraction

### Application Purpose

- Scan directories for audio files
- Generate acoustic fingerprints for each file
- Identify duplicates based on audio content (not just metadata)
- Allow users to safely remove duplicate files
- Preserve highest quality versions automatically

## 📁 Current Project Structure

```
AudioDUPER/
├── src/
│   ├── main.js              # Main Electron process (PRIMARY FILE)
│   ├── preload.js           # Secure bridge between main and renderer
│   ├── index.html           # Main UI interface
│   └── assets/              # Icons and static resources
├── scripts/
│   ├── build-compile-dist.sh    # Enhanced build script
│   ├── compile-build-dist-comprehensive.sh  # Full build
│   ├── bloat-check.sh           # Dependency analysis
│   └── temp-cleanup.sh          # System cleanup
├── docs/                   # Documentation files
├── build-resources/        # Build assets (icons, entitlements)
├── tests/                  # Test files (ready for implementation)
└── archive/                # Deprecated files (do not use)
```

## 🔧 Development Commands

### Essential Commands (Use These)

```bash
# Start development
npm run dev                 # Start with debugging enabled
npm start                   # Normal start

# Building
npm run build               # Build for current platform
npm run dist:current        # Build distributable for current platform
npm run dist:all            # Build for all platforms (macOS, Windows, Linux)
npm run dist:maximum        # Build ALL variants (comprehensive)

# Testing and Quality
npm test                    # Run tests (currently basic)
npm run lint                # Run linting (currently basic)

# Utilities
npm run bloat-check         # Analyze dependency sizes
npm run temp-clean          # Clean temporary files
npm run clean               # Clean build artifacts
```

### Advanced Build Commands

```bash
# Enhanced build script with options
./scripts/build-compile-dist.sh --help
./scripts/build-compile-dist.sh --parallel --skip-tests

# Comprehensive multi-platform build
./scripts/compile-build-dist-comprehensive.sh
```

## 🚨 Critical Development Rules

### 1. File Structure Guidelines

- **NEVER** modify files in `archive/` - these are deprecated
- **ALWAYS** place new source code in `src/`
- **USE** `scripts/` for build and utility scripts
- **DOCUMENT** new features in `docs/`

### 2. Package.json Updates

- **UPDATE** file paths when adding new source files
- **MAINTAIN** semantic versioning
- **KEEP** scripts section organized and consistent
- **ENSURE** main entry point points to `src/main.js`

### 3. Build System Integration

- **TEST** build scripts after modifications
- **MAINTAIN** cross-platform compatibility
- **USE** existing build infrastructure
- **PRESERVE** comprehensive build capabilities

## 🏗️ Architecture Patterns

### Main Process (src/main.js)

```javascript
// Primary responsibilities:
- Application lifecycle
- Window management
- File system operations
- Audio processing coordination
- IPC communication

// Key patterns to follow:
- Use async/await for file operations
- Implement proper error handling
- Use IPC for renderer communication
- Clean up resources on exit
```

### Preload Script (src/preload.js)

```javascript
// Security boundary:
- Expose safe APIs to renderer
- Validate all inputs
- Use contextBridge for security
- Never expose Node.js APIs directly
```

### Renderer Process (src/index.html)

```javascript
// UI responsibilities:
- User interface
- Display results
- User input handling
- Progress feedback

// Communication:
- Use IPC for main process communication
- Never access file system directly
- Implement proper error display
```

## 🔄 Standard Development Workflow

### When Making Changes:

1. **Analyze Impact**
   - Check which files need modification
   - Consider build system updates
   - Plan documentation updates

2. **Implement Changes**
   - Backup files before editing (MANDATORY)
   - Update package.json if needed
   - Test incrementally

3. **Update Build System**
   - Modify scripts if adding new processes
   - Test build commands work
   - Ensure cross-platform compatibility

4. **Documentation**
   - Update relevant docs in `docs/`
   - Update README.md if user-facing
   - Add inline code comments

5. **Testing**
   - Run `npm test` if tests exist
   - Test build process: `npm run build`
   - Test application: `npm run dev`

### File Backup Protocol (MANDATORY)

```bash
# BEFORE editing ANY file:
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
cp "file.js" "file.js.backup.$TIMESTAMP"

# Keep only 5 latest backups automatically
BACKUP_COUNT=$(ls -1 file.js.backup.* 2>/dev/null | wc -l)
if [ $BACKUP_COUNT -ge 6 ]; then
    OLDEST_BACKUP=$(ls -1t file.js.backup.* | tail -1)
    rm "$OLDEST_BACKUP"
fi
```

## 🎵 Audio Processing Guidelines

### Supported Formats

- **MP3** (.mp3) - Primary format
- **FLAC** (.flac) - Lossless support
- **WAV** (.wav) - Uncompressed
- **M4A/AAC** (.m4a, .aac) - Apple formats
- **OGG Vorbis** (.ogg) - Open source
- **Opus** (.opus) - Modern format
- **WMA** (.wma) - Windows format

### Quality Ranking Algorithm

```javascript
// File quality priority (higher is better):
1. Bitrate (lossless > high bitrate > low bitrate)
2. File size (larger usually better quality)
3. Format preference (FLAC > WAV > MP3 320 > MP3 256 > etc)
4. Modification date (newer often remastered)
```

### Error Handling Patterns

```javascript
// Always implement proper error handling:
try {
  const fingerprint = await generateFingerprint(filePath);
  return fingerprint;
} catch (error) {
  console.error(`Failed to process ${filePath}:`, error);
  // Return null or appropriate fallback
  return null;
}
```

## 📦 Build System Requirements

### Essential Build Targets

- **macOS**: DMG installer, ZIP archive, APP bundle
- **Windows**: EXE installer, MSI, portable version
- **Linux**: AppImage, DEB, RPM packages

### Build Script Standards

- **COLOR OUTPUT**: Use colored terminal output
- **PROGRESS INDICATORS**: Show build progress
- **ERROR HANDLING**: Proper error messages and cleanup
- **CROSS-PLATFORM**: Work on macOS, Windows, Linux
- **TEMP CLEANUP**: Automatic cleanup of build artifacts

### Package.json Build Configuration

```json
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
    }
}
```

## 🧪 Testing Standards

### When Adding Tests:

1. **Unit Tests**: Test individual functions
2. **Integration Tests**: Test component interactions
3. **End-to-End Tests**: Test complete workflows
4. **Performance Tests**: Test with large file sets

### Test File Organization

```
tests/
├── unit/                   # Unit tests
│   ├── main.test.js       # Main process tests
│   ├── audio.test.js      # Audio processing tests
│   └── utils.test.js      # Utility function tests
├── integration/            # Integration tests
│   ├── file-ops.test.js   # File operation tests
│   └── ui.test.js         # UI interaction tests
└── fixtures/              # Test data
    ├── samples/           # Sample audio files
    └── configs/          # Test configurations
```

## 🔒 Security Considerations

### Critical Security Rules:

1. **NEVER** expose Node.js APIs directly to renderer
2. **ALWAYS** validate user inputs in preload script
3. **USE** contextBridge for secure renderer communication
4. **SANITIZE** file paths to prevent directory traversal
5. **VALIDATE** audio files before processing

### File Security Patterns

```javascript
// In preload script - secure file path validation
const validatePath = userPath => {
  // Prevent directory traversal
  if (userPath.includes('..')) return false;
  // Ensure path is within allowed directories
  return path.resolve(userPath).startsWith(allowedBasePath);
};
```

## 🎨 UI/UX Guidelines

### Design Principles:

- **Dark Theme**: Primary interface theme
- **Progress Indicators**: Show progress for long operations
- **Clear Feedback**: Immediate response to user actions
- **Error Messages**: Helpful, actionable error messages
- **Responsive Design**: Work on different screen sizes

### Standard UI Patterns:

```javascript
// Progress indicator
ipcRenderer.send('show-progress', {
  message: 'Processing audio files...',
  current: 45,
  total: 100,
});

// Error display
ipcRenderer.send('show-error', {
  title: 'Processing Failed',
  message: 'Could not read audio file: song.mp3',
});
```

## 📝 Documentation Standards

### Required Documentation:

1. **README.md**: User-facing documentation
2. **DEVELOPMENT.md**: Development setup and guide
3. **API docs**: For any APIs exposed
4. **CHANGELOG.md**: Version history and changes

### Documentation Style:

- **Clear Headings**: Use consistent heading structure
- **Code Examples**: Provide working code examples
- **Command Examples**: Show exact commands to run
- **Cross-References**: Link to related documentation

## 🚀 Performance Optimization

### Memory Management:

- **CLEANUP**: Remove file watchers and timers on exit
- **STREAMING**: Use streams for large file processing
- **CACHING**: Cache results appropriately
- **WORKERS**: Use worker threads for CPU-intensive tasks

### File Processing:

- **BATCHING**: Process files in manageable batches
- **PARALLEL**: Use controlled parallelism
- **PROGRESS**: Report progress during long operations
- **ERROR RECOVERY**: Handle individual file failures gracefully

## 🔧 Common Development Tasks

### Adding New Audio Format Support:

1. Update format list in documentation
2. Add format validation in preload script
3. Test with sample files
4. Update build configuration if needed

### Updating Build Process:

1. Test current build first
2. Update build scripts
3. Test on all target platforms
4. Update documentation

### Adding New Dependencies:

1. Add to package.json
2. Run `npm install`
3. Update build configuration if needed
4. Test with `npm run build`
5. Update documentation

## ⚠️ Common Pitfalls to Avoid

### ❌ Don't Do:

- Modify files in `archive/` directory
- Forget to update package.json paths
- Skip testing build process
- Expose Node.js APIs to renderer
- Ignore cross-platform compatibility
- Forget error handling
- Skip documentation updates

### ✅ Do:

- Always backup files before editing
- Test build commands after changes
- Use secure IPC patterns
- Handle errors gracefully
- Update documentation
- Consider cross-platform compatibility
- Follow existing code patterns

## 🆘 Getting Help

### When Stuck:

1. **Check Logs**: Look for error messages in console
2. **Review Documentation**: Check relevant docs files
3. **Test Incrementally**: Isolate the problem
4. **Review Similar Code**: Look at existing patterns
5. **Document Issues**: Create GitHub issues if needed

### Debug Commands:

```bash
# Start with debugging
npm run dev

# Verbose logging
DEBUG=* npm start

# Test specific functionality
npm test -- --grep "audio processing"
```

---

**Remember**: This is a professional, production-ready application. Maintain high code quality, comprehensive testing, and excellent documentation. When in doubt, ask for clarification rather than making assumptions.

**AudioDUPER Team** 🎵
