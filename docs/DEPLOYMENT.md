# 🚀 Deployment Guide

This guide covers deploying AudioDUPER to various platforms, including distribution channels, release processes, and maintenance procedures.

## Table of Contents

- [Deployment Overview](#deployment-overview)
- [Platform Deployment](#platform-deployment)
- [Distribution Channels](#distribution-channels)
- [Release Process](#release-process)
- [Automated Deployment](#automated-deployment)
- [Maintenance](#maintenance)
- [Monitoring](#monitoring)

## Deployment Overview

### Deployment Strategy

AudioDUPER follows a multi-platform deployment strategy:

1. **Direct Downloads** - Primary distribution method
2. **Package Managers** - Platform-specific installers
3. **GitHub Releases** - Source of truth for releases
4. **Auto-Updates** - Built-in update mechanism

### Release Cadence

- **Major Releases**: 2-3 times per year (significant features)
- **Minor Releases**: Monthly (new features, improvements)
- **Patch Releases**: As needed (bug fixes, security)

### Version Management

Following [Semantic Versioning](https://semver.org/):

- **MAJOR**: Breaking changes or major features
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes (backward compatible)

## Platform Deployment

### macOS Deployment

#### Build Targets

```bash
# Standard builds
npm run build:mac          # Build for current architecture
npm run build:mac-arm64   # Apple Silicon only
npm run build:mac-x64     # Intel only

# Distribution builds
npm run dist:mac           # DMG and ZIP
npm run dist:mac-dmg       # DMG only
npm run dist:mac-zip       # ZIP only
```

#### Code Signing

```bash
# Import certificate
security import-certificate -k ~/Library/Keychains/login.keychain-db \
  certificate.p12

# Sign application
codesign --force --deep --sign "Developer ID Application: Your Name" \
  dist/AudioDUPER.app

# Verify signature
codesign --verify --verbose dist/AudioDUPER.app
```

#### Notarization

```bash
# Create DMG for notarization
npm run dist:mac-dmg

# Upload for notarization
xcrun altool --notarize-app \
  --primary-bundle-id "com.audiodedupe.app" \
  --username "your@email.com" \
  --password "@keychain:AC_PASSWORD" \
  --file dist/AudioDUPER.dmg

# Staple notarization ticket
xcrun stapler staple dist/AudioDUPER.dmg
```

#### App Store Distribution (Future)

```json
// package.json app store configuration
{
  "build": {
    "mac": {
      "category": "public.app-category.music",
      "hardenedRuntime": true,
      "gatekeeperAssess": false,
      "entitlements": "build-resources/entitlements.mac.plist"
    }
  }
}
```

### Windows Deployment

#### Build Targets

```bash
# Standard builds
npm run build:win           # Build for current architecture
npm run build:win-x64       # 64-bit only
npm run build:win-ia32      # 32-bit only

# Distribution builds
npm run dist:win            # NSIS installer
npm run dist:win-msi        # MSI installer
npm run dist:win-portable   # Portable version
```

#### Code Signing

```bash
# Import certificate
certutil -importPFX certificate.pfx -p password

# Sign application
signtool sign /f certificate.pfx /p password \
  /t http://timestamp.digicert.com \
  /fd sha256 dist/AudioDUPER.exe

# Verify signature
signtool verify /pa dist/AudioDUPER.exe
```

#### Installer Configuration

```json
// installer.nsh (NSIS script)
!define APP_NAME "AudioDUPER"
!define APP_VERSION "1.0.0"
!define APP_PUBLISHER "AudioDUPER Team"
!define APP_URL "https://github.com/sanchez314c/audio-duper"

Section "MainSection" SEC01
  SetOutPath "$PROGRAMFILES\${APP_NAME}"
  File /r "dist\win-unpacked\*"
  CreateShortCut "$DESKTOP\${APP_NAME}.lnk" "$PROGRAMFILES\${APP_NAME}\AudioDUPER.exe"
SectionEnd
```

### Linux Deployment

#### Build Targets

```bash
# Standard builds
npm run build:linux           # Build for current architecture
npm run build:linux-x64       # 64-bit only
npm run build:linux-arm64      # ARM64 only

# Distribution builds
npm run dist:linux            # All formats
npm run dist:linux-appimage   # AppImage only
npm run dist:linux-deb        # DEB package
npm run dist:linux-rpm        # RPM package
```

#### AppImage Creation

```bash
# Create AppImage
npm run build:linux-appimage

# Optimize AppImage
appimagetool --appimage-extract-and-repack \
  --comp gzip \
  dist/AudioDUPER.AppImage
```

#### DEB Package

```bash
# Create DEB
npm run dist:linux-deb

# Package information
Package: audioduper
Version: 1.0.0
Section: sound
Priority: optional
Architecture: amd64
Depends: libgtk-3-0, libnotify4, libnss3, libxss1
```

#### RPM Package

```bash
# Create RPM
npm run dist:linux-rpm

# Spec file
Name: audioduper
Version: 1.0.0
Release: 1%{?dist}
Summary: Audio duplicate detection tool
License: MIT
Group: Applications/Multimedia
```

## Distribution Channels

### GitHub Releases

#### Primary Distribution

```bash
# Create release
gh release create v1.0.0 \
  --title "AudioDUPER v1.0.0" \
  --notes "Release notes here" \
  dist/*

# Upload assets
gh release upload v1.0.0 dist/AudioDUPER.dmg
gh release upload v1.0.0 dist/AudioDUPER.exe
gh release upload v1.0.0 dist/AudioDUPER.AppImage
```

#### Release Template

```markdown
# AudioDUPER v{VERSION}

## 🎵 What's New

### Features

- Feature 1 description
- Feature 2 description

### Improvements

- Improvement 1 description
- Improvement 2 description

### Bug Fixes

- Bug fix 1 description
- Bug fix 2 description

## 📦 Downloads

| Platform         | Download                              | Checksum    |
| ---------------- | ------------------------------------- | ----------- |
| macOS (DMG)      | [AudioDUPER-{VERSION}.dmg](...)       | SHA256: ... |
| Windows (EXE)    | [AudioDUPER-Setup-{VERSION}.exe](...) | SHA256: ... |
| Linux (AppImage) | [AudioDUPER-{VERSION}.AppImage](...)  | SHA256: ... |

## 🔐 Verification

- **macOS**: Verify code signature and notarization
- **Windows**: Verify digital signature
- **Linux**: Verify GPG signature (when available)

## 📋 System Requirements

- **macOS**: 10.15+ (Catalina or later)
- **Windows**: 10+ (with updates)
- **Linux**: Most modern distributions

---

_Full changelog: [CHANGELOG.md](../CHANGELOG.md)_
```

### Website Distribution

#### Download Page Structure

```html
<section id="downloads">
  <h2>Download AudioDUPER</h2>

  <div class="platform-tabs">
    <button class="tab active" data-platform="mac">macOS</button>
    <button class="tab" data-platform="windows">Windows</button>
    <button class="tab" data-platform="linux">Linux</button>
  </div>

  <div class="download-content">
    <!-- Dynamic content based on selected platform -->
  </div>
</section>
```

#### CDN Integration

```javascript
// CDN configuration
const CDN_CONFIG = {
  baseUrl: 'https://cdn.audioduper.com/releases',
  fallback: 'https://github.com/sanchez314c/audio-duper/releases',
};

// Latest version check
async function getLatestVersion() {
  try {
    const response = await fetch(`${CDN_CONFIG.baseUrl}/latest.json`);
    return await response.json();
  } catch {
    return await fetch(`${CDN_CONFIG.fallback}/latest`);
  }
}
```

### Package Managers

#### Homebrew (macOS)

```ruby
# Formula (audioduper.rb)
class AudioDuper < Formula
  desc "Audio duplicate detection tool"
  homepage "https://github.com/sanchez314c/audio-duper"
  url "https://github.com/sanchez314c/audio-duper/archive/v#{version}.tar.gz"
  sha256 "..."
  license "MIT"

  depends_on "chromaprint"

  def install
    system "npm", "install", *std_args
    bin.install_symlink "dist/AudioDUPER.app/Contents/MacOS/AudioDUPER", "audioduper"
  end
end
```

#### Chocolatey (Windows)

```xml
<!-- chocolatey/package.nuspec -->
<?xml version="1.0" encoding="utf-8"?>
<package xmlns="http://schemas.microsoft.com/packaging/2015/06/nuspec.xsd">
  <metadata>
    <id>audioduper</id>
    <version>1.0.0</version>
    <title>AudioDUPER</title>
    <authors>AudioDUPER Team</authors>
    <projectUrl>https://github.com/sanchez314c/audio-duper</projectUrl>
    <licenseUrl>https://github.com/sanchez314c/audio-duper/blob/main/LICENSE</licenseUrl>
    <requireLicenseAcceptance>false</requireLicenseAcceptance>
    <projectSourceUrl>https://github.com/sanchez314c/audio-duper</projectSourceUrl>
    <docsUrl>https://github.com/sanchez314c/audio-duper/blob/main/README.md</docsUrl>
    <copyright>2024 AudioDUPER Team</copyright>
    <tags>audio duplicate finder music</tags>
    <summary>Find and manage duplicate audio files</summary>
    <description>AudioDUPER uses advanced audio fingerprinting to identify duplicate audio files based on actual content, not just metadata.</description>
  </metadata>
  <files>
    <file src="tools\**" target="tools" />
  </files>
</package>
```

#### Snap (Linux)

```yaml
# snap/snapcraft.yaml
name: audioduper
version: '1.0.0'
summary: Audio duplicate detection tool
description: |
  AudioDUPER identifies duplicate audio files using acoustic fingerprinting technology.
grade: stable
confinement: strict
base: core20
apps:
  audioduper:
    command: bin/audioduper
    plugs:
      - home
      - removable-media
parts:
  audioduper:
    plugin: nodejs
    source: .
    build-snaps: [npm-install]
```

## Release Process

### Pre-Release Checklist

#### Code Quality

- [ ] All tests pass
- [ ] Code coverage meets requirements
- [ ] Linting passes
- [ ] Security scan passes
- [ ] Documentation updated

#### Build Verification

- [ ] All platforms build successfully
- [ ] Code signatures valid
- [ ] Installers work on clean systems
- [ ] Auto-updater configured

#### Release Preparation

- [ ] Version number updated
- [ ] CHANGELOG.md updated
- [ ] Release notes prepared
- [ ] Assets generated
- [ ] Checksums calculated

### Release Steps

#### 1. Create Release Build

```bash
# Comprehensive build
npm run dist:maximum

# Verify all artifacts
ls -la dist/
# Should include:
# - AudioDUPER-1.0.0.dmg
# - AudioDUPER-Setup-1.0.0.exe
# - AudioDUPER-1.0.0.AppImage
# - AudioDUPER-1.0.0.deb
# - AudioDUPER-1.0.0.rpm
```

#### 2. Generate Checksums

```bash
# Generate SHA256 checksums
cd dist
sha256sum * > checksums.txt

# Format checksums.txt
cat > checksums.txt << EOF
AudioDUPER-1.0.0.dmg  SHA256  $(sha256sum AudioDUPER-1.0.0.dmg | cut -d' ' -f1)
AudioDUPER-Setup-1.0.0.exe  SHA256  $(sha256sum AudioDUPER-Setup-1.0.0.exe | cut -d' ' -f1)
AudioDUPER-1.0.0.AppImage  SHA256  $(sha256sum AudioDUPER-1.0.0.AppImage | cut -d' ' -f1)
EOF
```

#### 3. Create GitHub Release

```bash
# Create release with assets
gh release create v1.0.0 \
  --title "AudioDUPER v1.0.0" \
  --notes-file RELEASE_NOTES.md \
  --latest \
  dist/* \
  checksums.txt
```

#### 4. Update Distribution Channels

```bash
# Update website
./scripts/update-website.sh v1.0.0

# Update package managers
./scripts/update-homebrew.sh v1.0.0
./scripts/update-chocolatey.sh v1.0.0
./scripts/update-snap.sh v1.0.0
```

## Automated Deployment

### GitHub Actions Workflow

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
        os: [ubuntu-latest, windows-latest, macos-latest]

    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'

      - name: Install dependencies
        run: npm ci

      - name: Build
        run: npm run build

      - name: Package
        run: npm run dist

      - name: Upload artifacts
        uses: actions/upload-artifact@v3
        with:
          name: ${{ matrix.os }}-build
          path: dist/

      - name: Create Release
        if: matrix.os == 'ubuntu-latest'
        uses: softprops/action-gh-release@v1
        with:
          files: dist/*
          draft: false
          prerelease: false
```

### Deployment Scripts

#### Automated Release Script

```bash
#!/bin/bash
# scripts/release.sh

set -e

VERSION=$1
if [ -z "$VERSION" ]; then
  echo "Usage: $0 <version>"
  exit 1
fi

echo "Releasing AudioDUPER v$VERSION"

# Update version
npm version $VERSION

# Build all platforms
npm run dist:maximum

# Generate checksums
cd dist
sha256sum * > checksums.txt

# Create GitHub release
gh release create v$VERSION \
  --title "AudioDUPER v$VERSION" \
  --notes "Release v$VERSION" \
  dist/* checksums.txt

echo "Release v$VERSION completed successfully!"
```

## Maintenance

### Update Management

#### Auto-Updater Configuration

```javascript
// main.js
const { autoUpdater } = require('electron-updater');

app.on('ready', () => {
  autoUpdater.checkForUpdatesAndNotify();
});

autoUpdater.on('update-available', info => {
  dialog.showMessageBox({
    type: 'info',
    title: 'Update Available',
    message: `Version ${info.version} is available. Current version: ${app.getVersion()}`,
    buttons: ['Download', 'Later'],
  });
});
```

#### Telemetry (Optional)

```javascript
// Optional usage statistics (opt-in only)
const telemetry = {
  enabled: false,

  async track(event, data) {
    if (!this.enabled) return;

    try {
      await fetch('https://api.audioduper.com/telemetry', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ event, data, version: app.getVersion() }),
      });
    } catch {
      // Silently fail
    }
  },
};
```

### Security Updates

#### Vulnerability Scanning

```bash
# Automated security scan
npm audit --audit-level moderate

# Dependency check
npm outdated

# Security audit
npx audit-ci --moderate
```

#### Patch Management

```bash
# Security patch process
1. Identify vulnerability
2. Assess impact
3. Develop patch
4. Test thoroughly
5. Release as patch version
6. Notify users
```

## Monitoring

### Analytics

#### Download Tracking

```javascript
// Website analytics
const trackDownload = (platform, version) => {
  gtag('event', 'download', {
    event_category: 'engagement',
    event_label: `${platform}-${version}`,
    value: 1,
  });
};
```

#### Usage Metrics

```javascript
// Application metrics (opt-in)
const metrics = {
  init() {
    if (!localStorage.getItem('telemetry-opt-in')) return;

    setInterval(
      () => {
        this.reportUsage();
      },
      24 * 60 * 60 * 1000
    ); // Daily
  },

  reportUsage() {
    const data = {
      version: app.getVersion(),
      platform: process.platform,
      uptime: process.uptime(),
      memoryUsage: process.getProcessMemoryInfo(),
    };

    this.sendMetrics(data);
  },
};
```

### Error Reporting

```javascript
// Crash reporting
const crashReporter = require('electron').crashReporter;

crashReporter.start({
  productName: 'AudioDUPER',
  companyName: 'AudioDUPER Team',
  submitURL: 'https://crash.audioduper.com/report',
  uploadToServer: true,
});
```

## Best Practices

### Release Management

1. **Semantic Versioning** - Follow semver strictly
2. **Changelog Maintenance** - Document all changes
3. **Backward Compatibility** - Minimize breaking changes
4. **Security First** - Review for security issues
5. **Testing** - Test on all target platforms

### Deployment Safety

1. **Staged Rollout** - Release to subset first
2. **Rollback Plan** - Ability to revert quickly
3. **Monitoring** - Watch for issues post-release
4. **Communication** - Clear release notes and instructions

### User Experience

1. **Smooth Updates** - Minimize disruption
2. **Clear Messaging** - Explain changes and benefits
3. **Fallback Options** - Manual download available
4. **Support Ready** - Documentation and help available

---

_For deployment questions or issues, contact the AudioDUPER team or create an issue on GitHub._
