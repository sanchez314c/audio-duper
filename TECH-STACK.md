# Tech Stack for AudioDUPER

## Overview
AudioDUPER is an Electron-based desktop application for audio file duplication and management.

## Technology Stack

### Core Framework
- **Electron** - Cross-platform desktop app framework
  - Chromium rendering engine
  - Node.js runtime environment
  - Native OS integration

### Frontend
- **HTML5/CSS3/JavaScript** - Web technologies for UI
- Custom HTML interface (html_interface.html)
- Basic styling and layout

### Backend
- **Node.js** - JavaScript runtime
- **Electron APIs** - Desktop integration and file system access

### Dependencies
- **Electron** - Main framework
- Standard Node.js modules
- File system utilities

### Project Structure
- **main.js** - Electron main process
- **main_electron.js** - Additional Electron logic
- **html_interface.html** - Main UI interface
- **package.json** - Node.js dependencies and configuration

### Build and Distribution
- **Electron Builder** - For creating distributables
- Cross-platform support (Windows, macOS, Linux)

### Development Tools
- Node.js and npm
- Electron development environment

## Architecture
- Main process handles system operations and file management
- Renderer process manages the HTML interface
- Direct file system access for audio operations

## Target Platforms
- Windows (x64, x86)
- macOS (Intel, ARM64)
- Linux (x64, ARM64)

## Build Process
Uses Electron Builder for creating platform-specific installers and binaries.