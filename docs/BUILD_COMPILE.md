# 🔧 Build & Compile Guide

This comprehensive guide covers building, compiling, and distributing AudioDUPER across all supported platforms.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Development Build](#development-build)
- [Production Build](#production-build)
- [Platform-Specific Builds](#platform-specific-builds)
- [Distribution](#distribution)
- [Build Scripts](#build-scripts)
- [Troubleshooting](#troubleshooting)

## Prerequisites

### Required Tools

All platforms require:

- **Node.js** 16+ (recommend 18 LTS)
- **npm** 8+ or **yarn** 1.22+
- **Git** 2.20+

### Platform-Specific Requirements

#### macOS

```bash
# Install Xcode Command Line Tools
xcode-select --install

# Install build dependencies
brew install node npm git

# Optional: For code signing
brew install --cask xcode
```

#### Windows

- [Visual Studio Build Tools](https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2022)
- [Windows SDK](https://developer.microsoft.com/en-us/windows/downloads/windows-sdk/)
- [Node.js](https://nodejs.org/) (includes npm)

#### Linux

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install build-essential nodejs npm git

# Fedora
sudo dnf install @development-tools nodejs npm git

# Arch Linux
sudo pacman -S base-devel nodejs npm git
```

## Development Build

### Quick Start

```bash
# Clone repository
git clone https://github.com/sanchez314c/audio-duper.git
cd audio-duper

# Install dependencies
npm install

# Start development mode
npm run dev
```

### Development Commands

```bash
# Start with debugging enabled
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

### Development Features

- **Hot Reload**: Automatic restart on file changes
- **DevTools**: Chrome DevTools for debugging
- **Verbose Logging**: Detailed console output
- **Source Maps**: Easy debugging of minified code

## Production Build

### Basic Build

```bash
# Build for current platform
npm run build

# Build for specific platforms
npm run build:mac
npm run build:win
npm run build:linux
```

### Build Output

```
dist/
├── AudioDUPER.app          # macOS application bundle
├── AudioDUPER.exe          # Windows executable
├── audio-duper            # Linux executable
└── resources/             # Application assets
```

## Platform-Specific Builds

### macOS Builds

#### Standard Build

```bash
# Build for macOS
npm run build:mac

# Output: dist/AudioDUPER.app
```

#### Code Signing (Optional)

```bash
# Install certificate first
security import-certificate -k ~/Library/Keychains/login.keychain-db certificate.p12

# Build with signing
npm run build:mac -- --mac.certificateIdentity="Developer ID Application: Your Name"
```

#### Notarization (Optional)

```bash
# Upload for notarization
xcrun altool --notarize-app \
  --primary-bundle-id "com.audiodedupe.app" \
  --username "your@email.com" \
  --password "@keychain:AC_PASSWORD" \
  --file dist/AudioDUPER.dmg
```

### Windows Builds

#### Standard Build

```bash
# Build for Windows
npm run build:win

# Output: dist/AudioDUPER Setup.exe
```

#### Code Signing (Optional)

```bash
# Install certificate first
certutil -importPFX certificate.pfx

# Build with signing
npm run build:win -- --win.certificateFile="certificate.pfx" \
  --win.certificatePassword="password"
```

#### Installer Options

```bash
# Create MSI installer
npm run build:win -- --win.target=msi

# Create portable version
npm run build:win -- --win.portable=true
```

### Linux Builds

#### Standard Build

```bash
# Build for Linux
npm run build:linux

# Output: dist/audio-duper.AppImage
```

#### Package Formats

```bash
# Create AppImage
npm run build:linux -- --linux.target=AppImage

# Create DEB package
npm run build:linux -- --linux.target=deb

# Create RPM package
npm run build:linux -- --linux.target=rpm
```

## Distribution

### All Platforms Build

```bash
# Build for all platforms
npm run dist:all

# Output in dist/
├── AudioDUPER-1.0.0.dmg        # macOS disk image
├── AudioDUPER Setup 1.0.0.exe   # Windows installer
├── AudioDUPER-1.0.0.AppImage     # Linux AppImage
├── AudioDUPER-1.0.0.deb          # Debian package
└── AudioDUPER-1.0.0.rpm          # Red Hat package
```

### Maximum Build (All Variants)

```bash
# Build ALL variants for comprehensive distribution
npm run dist:maximum

# Includes:
- macOS: DMG, ZIP, APP
- Windows: EXE, MSI, portable
- Linux: AppImage, DEB, RPM, TAR
```

### Build Configuration

The build configuration is in `package.json`:

```json
{
  "build": {
    "appId": "com.audiodedupe.app",
    "productName": "AudioDUPER",
    "directories": {
      "output": "dist",
      "buildResources": "build-resources"
    },
    "files": [
      "src/main.js",
      "src/preload.js",
      "src/index.html",
      "package.json"
    ],
    "mac": {
      "category": "public.app-category.music",
      "target": [
        {
          "target": "dmg",
          "arch": ["x64", "arm64"]
        },
        {
          "target": "zip",
          "arch": ["x64", "arm64"]
        }
      ]
    },
    "win": {
      "target": [
        {
          "target": "nsis",
          "arch": ["x64", "ia32"]
        },
        {
          "target": "portable",
          "arch": ["x64"]
        }
      ]
    },
    "linux": {
      "target": ["AppImage", "deb", "rpm"],
      "category": "AudioVideo"
    }
  }
}
```

## Build Scripts

### Enhanced Build Script

The `scripts/build-compile-dist.sh` script provides advanced build options:

```bash
# Show help
./scripts/build-compile-dist.sh --help

# Parallel builds
./scripts/build-compile-dist.sh --parallel

# Skip tests
./scripts/build-compile-dist.sh --skip-tests

# Verbose output
./scripts/build-compile-dist.sh --verbose

# Specific platforms only
./scripts/build-compile-dist.sh --platforms mac,win
```

### Comprehensive Build Script

The `scripts/compile-build-dist-comprehensive.sh` script handles full distribution builds:

```bash
# Full multi-platform build
./scripts/compile-build-dist-comprehensive.sh

# With code signing
./scripts/compile-build-dist-comprehensive.sh --sign

# With notarization
./scripts/compile-build-dist-comprehensive.sh --notarize
```

### Utility Scripts

#### Bloat Check

```bash
# Analyze dependency sizes
npm run bloat-check
# or
./scripts/bloat-check.sh
```

#### Temp Cleanup

```bash
# Clean temporary files
npm run temp-clean
# or
./scripts/temp-cleanup.sh
```

#### Clean Build

```bash
# Clean all build artifacts
npm run clean

# Deep clean (including node_modules)
npm run clean:deep
```

## Build Optimization

### Compression Settings

```json
{
  "compression": "maximum",
  "npmRebuild": true,
  "removePackageScripts": true,
  "nodeGypRebuild": true
}
```

### Resource Optimization

```javascript
// In build process
const optimization = {
  minify: true,
  treeShaking: true,
  codeSplitting: true,
  compression: true,
};
```

### Bundle Analysis

```bash
# Analyze bundle size
npm run build -- --analyze-bundle

# Check for large dependencies
npm run bloat-check
```

## Continuous Integration

### GitHub Actions

The `.github/workflows/ci.yml` defines automated builds:

```yaml
name: Build and Test
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
      - run: npm ci
      - run: npm test
      - run: npm run build
```

### Build Matrix

```yaml
strategy:
  matrix:
    os: [ubuntu-latest, windows-latest, macos-latest]
    node: [16, 18, 20]
```

## Troubleshooting

### Common Build Issues

#### "electron command not found"

```bash
# Install dependencies
npm install

# Install electron globally (not recommended)
npm install -g electron
```

#### "Module not found" errors

```bash
# Clean install
rm -rf node_modules package-lock.json
npm install
```

#### Build failures on macOS

```bash
# Clear electron cache
rm -rf ~/Library/Caches/electron

# Clean build artifacts
npm run clean

# Rebuild
npm run build
```

#### Windows code signing errors

```bash
# Check certificate store
certutil -store MY

# Verify certificate
signtool verify /v AudioDUPER.exe
```

#### Linux permission errors

```bash
# Fix permissions
chmod +x dist/audio-duper.AppImage

# Run as AppImage
./dist/audio-duper.AppImage
```

### Debug Builds

```bash
# Verbose logging
DEBUG=* npm run build

# Build with debug symbols
npm run build -- --debug

# Generate source maps
npm run build -- --source-map
```

### Performance Issues

```bash
# Increase Node.js memory limit
NODE_OPTIONS="--max-old-space-size=4096" npm run build

# Use faster package manager
npm install --prefer-offline
```

## Release Process

### Version Management

```bash
# Update version (patch/minor/major)
npm version patch

# This updates:
# - package.json version
# - Git tag
# - CHANGELOG.md
```

### Release Build

```bash
# Create comprehensive release build
npm run dist:maximum

# Generate changelog
npm run changelog

# Create GitHub release
gh release create v1.0.0 dist/* --generate-notes
```

### Distribution Channels

1. **GitHub Releases** - Primary distribution
2. **Direct Downloads** - From website
3. **Package Managers** - Future: Homebrew, Chocolatey, Snap

## Build Best Practices

### Before Building

1. **Update Dependencies**

   ```bash
   npm audit fix
   npm update
   ```

2. **Run Tests**

   ```bash
   npm test
   npm run lint
   ```

3. **Clean Environment**
   ```bash
   npm run clean
   ```

### During Build

1. **Monitor Output**
   - Check for warnings
   - Verify all targets built
   - Validate file sizes

2. **Test Artifacts**
   ```bash
   # Test built application
   ./dist/AudioDUPER.app/Contents/MacOS/AudioDUPER
   ```

### After Build

1. **Verify Signatures**

   ```bash
   # macOS
   codesign --verify --verbose dist/AudioDUPER.app

   # Windows
   signtool verify /pa dist/AudioDUPER.exe
   ```

2. **Test Installation**
   - Test on clean system
   - Verify all features work
   - Check uninstallation

3. **Document Release**
   - Update CHANGELOG.md
   - Create release notes
   - Update documentation

---

_For the most up-to-date build information, check the scripts directory and package.json build configuration._
