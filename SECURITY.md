# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| 1.0.x   | Yes       |

## Reporting a Vulnerability

If you discover a security vulnerability in AudioDUPER, please report it responsibly.

**Do not open a public GitHub issue for security vulnerabilities.**

Instead, please email **security@jasonpaulmichaels.com** or use [GitHub's private vulnerability reporting](https://github.com/sanchez314c/audio-duper/security/advisories/new).

### What to Include

- Description of the vulnerability
- Steps to reproduce
- Affected versions
- Potential impact
- Suggested fix (if you have one)

### Response Timeline

- **Acknowledgment**: Within 48 hours
- **Initial assessment**: Within 5 business days
- **Fix release**: Depends on severity, but we aim for patches within 14 days for critical issues

## Security Architecture

AudioDUPER is built with security as a core principle:

### Context Isolation

The Electron renderer process is fully sandboxed with `contextIsolation: true` and `nodeIntegration: false`. The renderer has zero direct access to Node.js APIs. All communication goes through the preload script's `contextBridge`, which exposes only validated, purpose-specific functions.

### Input Validation

Every IPC call from the renderer to the main process validates its inputs in the preload layer:

- Directory paths must be strings
- File path arrays are type-checked element by element
- Callbacks are validated as functions
- No raw IPC channel access is exposed to the renderer

### File System Access

- AudioDUPER only accesses directories the user explicitly selects via native OS dialogs
- Hidden files and system directories (`.git`, `node_modules`, `$RECYCLE.BIN`, etc.) are automatically skipped
- Symlink loops are detected and prevented via `realpath` tracking
- File operations (delete, move) validate file existence before acting

### No Network Access

AudioDUPER makes zero network calls during normal operation. All audio fingerprinting via Chromaprint/fpcalc and metadata extraction via music-metadata happen entirely on the local machine. No telemetry, no analytics, no phone-home behavior.

### Process Model

```
Renderer (sandboxed, no Node.js)
    |
    | contextBridge (validated API only)
    |
Preload (input validation layer)
    |
    | ipcRenderer.invoke / ipcRenderer.send
    |
Main Process (full Node.js, file system access)
    |
    +-- fpcalc (audio fingerprinting)
    +-- music-metadata (metadata parsing)
    +-- fs operations (scan, delete, move)
```

### Secure Defaults

- `enableRemoteModule: false`
- `sandbox: false` (required for fpcalc, but contextIsolation compensates)
- External links open in the system browser, not inside the app
- Application menu is removed for the frameless window
- DevTools are only available via environment variable (`OPEN_DEVTOOLS=1`)

## Dependencies

Run `npm audit` to check for known vulnerabilities in dependencies. We keep Electron and other dependencies updated to their latest stable versions.

## Disclosure Policy

We follow coordinated disclosure. Security fixes are released before public disclosure of the vulnerability details.

---

Maintained by [J. Michaels](https://github.com/sanchez314c)
