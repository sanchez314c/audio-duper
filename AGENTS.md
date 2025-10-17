# AudioDUPER - AI Agent Guide

## Overview
AudioDUPER is an Electron desktop app for finding and removing duplicate audio files using acoustic fingerprinting (Chromaprint).

## Quick Context
- **Stack**: Electron 39, Node.js 18+, JavaScript (ES2022)
- **Architecture**: 3-process Electron (main → preload → renderer)
- **Core class**: `AudioDedupe` in `src/main/main.js`
- **UI**: Single-file `src/renderer/index.html` with inline CSS/JS

## Key Files (Read These First)
| File | Purpose |
|------|---------|
| `src/main/main.js` | Main process, AudioDedupe class, IPC handlers |
| `src/preload/preload.js` | Security bridge, contextBridge API |
| `src/renderer/index.html` | Full UI (CSS + JS inline) |
| `src/shared/constants.js` | App name, version constants |
| `package.json` | Dependencies, build config, scripts |

## IPC Channels
**Invoke (renderer → main)**: select-folder, analyze-directory, scan-directory, cancel-scan, delete-files, move-files, select-destination-folder, get-app-info, play-audio-file
**Events (main → renderer)**: scan-progress, app-error

## Commands
```bash
npm install          # Install deps
npm run dev          # Dev mode
npm start            # Production
npm test             # Run tests
npm run lint         # Lint code
npm run build        # Build for current platform
```

## What NOT to Modify
- `src/preload/preload.js` security surface without understanding context isolation
- Build config in `package.json` without testing on target platform
- IPC channel names (would break renderer ↔ main communication)

## Architecture Rules
- All file system operations happen in main process only
- Renderer has NO direct Node.js access (context isolation)
- All IPC goes through preload bridge with input validation
- Concurrency uses Promise semaphore pool (NOT worker threads)

## Testing
- Framework: Jest (configured but minimal test coverage currently)
- Config: `jest.config.js`
- Run: `npm test`

## Known Limitations
- No fingerprint caching (rescans recalculate)
- Single-file renderer (3000+ lines, not modularized)
- No export functionality yet (CSV/JSON planned)
- No settings/preferences UI yet
