# Project: AudioDUPER

## Overview

Cross-platform Electron desktop application for intelligent audio duplicate detection and cleanup. Uses Chromaprint acoustic fingerprinting to identify duplicate audio files across music collections.

## Tech Stack

- **Framework**: Electron 39+
- **Language**: JavaScript/TypeScript
- **Runtime**: Node.js 18+
- **Audio Engine**: Chromaprint (via fpcalc)
- **Metadata**: music-metadata
- **Build**: electron-builder
- **Testing**: Jest
- **Linting**: ESLint 9, Prettier
- **CI/CD**: GitHub Actions

## Development Commands

- **Install**: `npm install`
- **Run (dev)**: `npm run dev`
- **Run (prod)**: `npm start`
- **Build**: `npm run build`
- **Build all platforms**: `npm run dist:all`
- **Test**: `npm test`
- **Test (coverage)**: `npm run test:coverage`
- **Lint**: `npm run lint`
- **Format**: `npm run format`
- **Type check**: `npm run type-check`
- **Clean**: `npm run clean`

## Key Files

- **Entry (main)**: `src/main.js` → `src/main/main.js`
- **Preload**: `src/preload.js` → `src/preload/preload.js`
- **Renderer**: `src/renderer/index.html`
- **Shared**: `src/shared/constants.js`
- **Build config**: `package.json` (build section)
- **Icons**: `build_resources/icons/`
- **Entitlements**: `build_resources/entitlements.mac.plist`

## Architecture

```
src/
  main/         - Electron main process (Node.js)
  preload/      - Preload scripts (secure IPC bridge)
  renderer/     - Frontend UI (HTML/CSS/JS)
  shared/       - Shared constants and utilities
```

- Main process handles file system access, audio fingerprinting via fpcalc
- Preload scripts bridge main/renderer via contextBridge
- Renderer shows UI, communicates via IPC

## Build Targets

- **macOS**: DMG, ZIP, PKG (x64 + arm64)
- **Windows**: NSIS, Portable, MSI (x64, ia32, arm64)
- **Linux**: AppImage, DEB, RPM, Snap, tar.gz (x64, arm64, armv7l)

## Notes

- Audio fingerprinting requires fpcalc binary (bundled via node_modules/fpcalc)
- Electron sandbox: on Linux, may need `--no-sandbox` or `sudo sysctl -w kernel.unprivileged_userns_clone=1`
- All audio processing is local - no external API calls
- Secure IPC: renderer is sandboxed with contextIsolation enabled
