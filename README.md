# 🎵 AudioDUPER

[![Build Status](https://github.com/sanchez314c/audio-duper/workflows/CI/badge.svg)](https://github.com/sanchez314c/audio-duper/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Release](https://img.shields.io/github/release/sanchez314c/audio-duper.svg)](https://github.com/sanchez314c/audio-duper/releases)
[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Windows%20%7C%20Linux-blue.svg)](https://github.com/sanchez314c/audio-duper/releases)

**Intelligent Audio Duplicate Detection & Cleanup**

AudioDUPER is a modern, cross-platform desktop application that uses advanced audio fingerprinting to identify and remove duplicate audio files from your music collection. Built with Electron and powered by Chromaprint technology.

![AudioDUPER Interface](build-resources/screenshots/main-interface.png)

## ✨ Key Features

- **🎯 Smart Detection**: Content-based duplicate detection using Chromaprint fingerprinting
- **🎨 Modern UI**: Beautiful, responsive interface with dark/light themes
- **📊 Detailed Analysis**: View bitrate, duration, file size, and format information
- **⚡ Fast Performance**: Multi-threaded processing with real-time progress
- **🛡️ Safe Operations**: Preview mode and confirmation dialogs prevent accidental deletions
- **📁 Batch Processing**: Handle large music libraries efficiently
- **🔄 Smart Sorting**: Keeps highest quality originals automatically

## 🚀 Quick Start

### 📦 Installation

**Option 1: Download Release (Recommended)**

1. Visit [Releases](https://github.com/sanchez314c/audio-duper/releases)
2. Download for your platform:
   - **macOS**: `AudioDUPER-x.x.x.dmg` (Intel) or `AudioDUPER-x.x.x-arm64.dmg` (Apple Silicon)
   - **Windows**: `AudioDUPER-Setup-x.x.x.exe`
   - **Linux**: `AudioDUPER-x.x.x.AppImage` or `AudioDUPER-x.x.x.deb`
3. Install and launch

**Option 2: Build from Source**

```bash
git clone https://github.com/sanchez314c/audio-duper.git
cd audio-duper
npm install
npm run build
npm run electron:dev  # Development mode
# or
npm run dist          # Build distribution
```

For detailed installation instructions, see [INSTALLATION.md](docs/INSTALLATION.md).

### 📖 Basic Usage

1. **📁 Select Folder**: Choose your audio directory
2. **🔍 Start Scan**: Begin duplicate detection
3. **📊 Review Results**: Browse duplicate groups with quality comparisons
4. **✅ Select Files**: Choose duplicates using smart selection tools
5. **🗑️ Delete**: Remove selected files safely with confirmation

For comprehensive usage guide, see [QUICK_START.md](docs/QUICK_START.md).

## 📚 Documentation

### 🚀 Quick Links

- **[📖 Documentation Index](docs/DOCUMENTATION_INDEX.md)** - Complete documentation navigation
- **[⚡ Quick Start Guide](docs/QUICK_START.md)** - 5-minute setup and usage
- **[🛠️ Installation Guide](docs/INSTALLATION.md)** - Detailed installation instructions
- **[❓ FAQ](docs/FAQ.md)** - Frequently asked questions

### 👥 User Documentation

- **[📖 User Guide](docs/USER_GUIDE.md)** - Complete user manual
- **[🔧 Configuration](docs/CONFIGURATION.md)** - Settings and preferences
- **[🔍 Troubleshooting](docs/TROUBLESHOOTING.md)** - Problem-solving guide

### 🛠️ Developer Documentation

- **[🚀 Development Setup](docs/DEVELOPMENT.md)** - Development environment setup
- **[🏗️ Architecture](docs/ARCHITECTURE.md)** - System architecture overview
- **[🔌 API Reference](docs/API.md)** - Complete API documentation
- **[🤝 Contributing](docs/CONTRIBUTING.md)** - Contribution guidelines

### 📋 Project Documentation

- **[📋 Product Requirements](docs/PRD.md)** - Product requirements document
- **[🛣️ Roadmap](docs/TODO.md)** - Development roadmap and tasks
- **[📊 Tech Stack](docs/TECHSTACK.md)** - Technology stack overview
- **[🔒 Security](docs/SECURITY.md)** - Security policy and procedures

## 🎯 Supported Formats

- **MP3** (.mp3) • **FLAC** (.flac) • **WAV** (.wav)
- **M4A/AAC** (.m4a, .aac) • **OGG Vorbis** (.ogg)
- **Opus** (.opus) • **WMA** (.wma)

## 🏆 Quality Algorithm

AudioDUPER automatically ranks files by:

1. **Bitrate** (higher is better)
2. **File size** (larger usually indicates better quality)
3. **Format preference** (lossless > high-quality lossy)
4. **Modification date** (newer versions often improved)

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](docs/CONTRIBUTING.md) for guidelines.

### Quick Development Setup

```bash
git clone https://github.com/sanchez314c/audio-duper.git
cd audio-duper
npm install
npm run dev  # Start development
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👤 Author

**Jasonn Michaels**

- GitHub: [@sanchez314c](https://github.com/sanchez314c)
- Email: [sanchez314c@jasonpaulmichaels.co](mailto:sanchez314c@jasonpaulmichaels.co)

## 📞 Support

- **[🔍 Troubleshooting](docs/TROUBLESHOOTING.md)** - Common issues and solutions
- **[🐛 Report Issues](https://github.com/sanchez314c/audio-duper/issues)** - Bug reports and feature requests
- **[💬 Discussions](https://github.com/sanchez314c/audio-duper/discussions)** - Community discussions

## 🔒 Security & Privacy

- **🔒 No telemetry**: AudioDUPER doesn't collect or transmit any data
- **🏠 Local processing**: All analysis happens on your device
- **🛡️ Secure by design**: Sandboxed renderer with contextual isolation
- **✅ File safety**: Multiple confirmation steps prevent accidental deletion

---

**Built with ❤️ by [Jasonn Michaels](https://github.com/sanchez314c)**

_AudioDUPER - Because life's too short for duplicate songs_ 🎵
