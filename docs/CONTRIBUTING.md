# Contributing to AudioDUPER

Thanks for your interest in contributing to AudioDUPER. This document covers everything you need to get started.

## Quick Start

```bash
git clone https://github.com/sanchez314c/audio-duper.git
cd audio-duper
npm install
npm run dev
```

## Requirements

- Node.js 18+ (see `.nvmrc`)
- npm 8+
- Git 2.30+
- Chromaprint/fpcalc (bundled via `node_modules/fpcalc`)

### Platform-Specific

- **macOS**: Xcode Command Line Tools
- **Windows**: Visual Studio Build Tools 2019+
- **Linux**: `build-essential`, `libgtk-3-dev`, `libasound2-dev`

## Development Workflow

1. Fork the repository on GitHub
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Make your changes in `src/`
4. Run tests: `npm test`
5. Run linting: `npm run lint`
6. Commit with conventional commits: `git commit -m "feat: add new feature"`
7. Push and open a pull request against `main`

## Code Standards

- ES6+ JavaScript with async/await
- ESLint config in `.eslintrc.json` and `eslint.config.js`
- Prettier formatting (see `.prettierrc`)
- JSDoc comments on exported functions
- Proper error handling with try/catch blocks

## Project Structure

```
src/
  main/main.js        - Electron main process, AudioDedupe class, IPC handlers
  preload/preload.js   - Secure context bridge (contextBridge.exposeInMainWorld)
  renderer/index.html  - Single-file UI with inline CSS/JS (Neo-Noir Glass theme)
  shared/constants.js  - Shared constants (APP_NAME, APP_VERSION)
```

## Key IPC Channels

The preload script exposes these APIs to the renderer via `window.electronAPI`:

- `selectFolder()` - Open native folder picker
- `analyzeDirectory(path)` - Pre-scan directory analysis
- `scanDirectory(path)` - Full fingerprint scan with progress
- `cancelScan()` - Cancel an in-progress scan
- `deleteFiles(paths[])` - Delete selected duplicate files
- `moveFiles(paths[], destination)` - Move files to a destination folder
- `playAudioFile(path)` - Load audio as base64 for playback
- `onScanProgress(callback)` - Listen for scan progress events

## Testing

```bash
npm test              # Run all tests
npm run test:coverage # Run with coverage report
npm run test:watch    # Watch mode
```

Tests live in `tests/` and use Jest. Target coverage: 90% statements, 85% branches.

## Commit Message Format

Use [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` new feature
- `fix:` bug fix
- `docs:` documentation only
- `style:` formatting, no logic change
- `refactor:` code restructuring
- `test:` adding/updating tests
- `chore:` build process, dependencies

## Pull Requests

- Fill out the PR template in `.github/PULL_REQUEST_TEMPLATE.md`
- Link related issues
- Include screenshots for UI changes
- All CI checks must pass
- At least one review approval required

## Bug Reports

Use the bug report template at `.github/ISSUE_TEMPLATE/bug_report.md`. Include your OS, AudioDUPER version, steps to reproduce, and console errors.

## Feature Requests

Use the feature request template at `.github/ISSUE_TEMPLATE/feature_request.md`.

## Security

If you find a security vulnerability, please report it privately. See [SECURITY.md](SECURITY.md) for details.

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Maintained by [J. Michaels](https://github.com/sanchez314c)
