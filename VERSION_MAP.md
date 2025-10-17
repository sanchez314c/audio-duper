# AudioDUPER - Version Map

## Overview

Cross-platform Electron application for audio duplicate detection using Chromaprint fingerprinting.

## Current Version

| Version | Status | Location | Description |
|---------|--------|----------|-------------|
| v1.0.0 | **Active** | Project root (`./`) | Current release |

## Technology Stack

- **Framework**: Electron 39+
- **Language**: JavaScript/TypeScript
- **Build**: electron-builder
- **Audio**: Chromaprint (fpcalc)
- **Testing**: Jest
- **Linting**: ESLint, Prettier

## Project Structure

```
audio-duper/                  <-- active version at root
├── src/
│   ├── main/                # Electron main process
│   ├── preload/             # Preload scripts
│   ├── renderer/            # Frontend code
│   └── shared/              # Shared utilities
├── build_resources/         # Build assets (icons, entitlements)
├── config/                  # Configuration files
├── docs/                    # Documentation (15 files)
├── scripts/                 # Build scripts
├── tests/                   # Test files
├── resources/icons/         # App icons
├── archive/                 # Timestamped backups (gitignored)
├── legacy/                  # Previous version folders (gitignored)
│   └── v0.0.1/             # Original pre-flatten state
├── package.json
├── CLAUDE.md
├── AGENTS.md
├── README.md
├── CHANGELOG.md
├── LICENSE
└── VERSION_MAP.md
```

## Legacy Versions

| Version | Location | Status | Notes |
|---------|----------|--------|-------|
| v0.0.1 | `legacy/v0.0.1/` | Archived | Original folder structure before flattening |

## Restructuring History

**2026-02-07**: Repository compliance audit (FULL mode)
- Flattened `v0.0.1/` contents to project root
- Moved original `v0.0.1/` to `legacy/v0.0.1/`
- Added `CLAUDE.md`, `AGENTS.md`
- Fixed package.json metadata (author, repository, bugs)
- Fixed LICENSE copyright holder
- Created `archive/`, `resources/icons/`
- Standardized run-source script naming
- Updated `.gitignore` with missing patterns

**2026-01-22**: Initial cleanup
- Removed duplicates and loose files to AI-Pre-Trash

---

*Last updated: 2026-02-07*
