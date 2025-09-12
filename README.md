# 🎵 AudioDUPER

**Intelligent Audio Duplicate Detection & Cleanup**

AudioDUPER is a modern, cross-platform desktop application that uses advanced audio fingerprinting to identify and remove duplicate audio files from your music collection. Built with Electron and powered by Chromaprint technology.

![AudioDUPER Interface](screenshot.png)

## ✨ Features

- **🎯 Smart Detection**: Content-based duplicate detection using Chromaprint fingerprinting
- **🎨 Modern UI**: Beautiful, responsive interface with dark/light themes
- **📊 Detailed Analysis**: View bitrate, duration, file size, and format information
- **🔍 Advanced Filtering**: Select duplicates by quality, format, or custom criteria  
- **⚡ Fast Performance**: Multi-threaded processing with real-time progress
- **🛡️ Safe Operations**: Preview mode and confirmation dialogs prevent accidental deletions
- **📁 Batch Processing**: Handle large music libraries efficiently
- **🔄 Smart Sorting**: Keeps highest quality originals automatically

## 🚀 Quick Start

### Prerequisites

- **Node.js** 16 or higher
- **Python** (for native dependencies)
- **System dependencies** for audio processing:
  - **macOS**: Install with `brew install chromaprint`
  - **Windows**: Download chromaprint binaries
  - **Linux**: Install with `apt install libchromaprint-tools` or equivalent

### Installation

1. **Clone or download** this repository
2. **Install dependencies**:
   ```bash
   npm install
   ```
3. **Start the application**:
   ```bash
   npm start
   ```

For development mode with debugging:
```bash
npm run dev
```

## 📖 How to Use

### Basic Workflow

1. **📁 Select Folder**: Click "Browse Folder" to choose your audio directory
2. **🔍 Start Scan**: Click "Start Scan" to begin duplicate detection
3. **📊 Review Results**: Browse detected duplicate groups with quality comparisons
4. **✅ Select Files**: Choose which duplicates to delete using smart selection tools
5. **🗑️ Delete**: Remove selected files safely with confirmation

### Smart Selection Tools

- **Select All Duplicates**: Choose all duplicate files, keeping originals
- **Select Lowest Quality**: Automatically pick the lowest quality version in each group
- **Custom Selection**: Manually choose which files to remove

### Understanding Results

Each duplicate group shows:
- **Original**: The highest quality file (kept by default)
- **Duplicates**: Lower quality versions (candidates for deletion)
- **Wasted Space**: Disk space that could be recovered
- **File Details**: Bitrate, duration, format, and file size

## 🛠️ Configuration

### Supported Audio Formats

- **MP3** (.mp3)
- **FLAC** (.flac) 
- **WAV** (.wav)
- **M4A/AAC** (.m4a, .aac)
- **OGG Vorbis** (.ogg)
- **Opus** (.opus)
- **WMA** (.wma)

### Quality Detection Algorithm

AudioDUPER ranks files by:
1. **Bitrate** (higher is better)
2. **File size** (larger usually indicates better quality)
3. **Format preference** (lossless > high-quality lossy)
4. **Modification date** (newer versions often improved)

## 🔧 Development

### Build from Source

```bash
# Install dependencies
npm install

# Run in development mode
npm run dev

# Build for production
npm run build

# Package for distribution
npm run dist
```

### Project Structure

```
AudioDUPER/
├── main.js              # Main Electron process
├── preload.js           # Secure preload script
├── index.html           # Modern UI interface
├── package.json         # Dependencies and scripts
├── assets/              # Icons and resources
└── dist/               # Built applications
```

### Dependencies

**Core:**
- `electron` - Cross-platform desktop framework
- `fpcalc` - Audio fingerprinting library
- `music-metadata` - Audio metadata extraction

**Build:**
- `electron-builder` - Application packaging

## 📦 Distribution

### Build Installers

```bash
# Build for current platform
npm run build

# Build for all platforms (requires additional setup)
npm run build:all
```

### Platform-Specific Builds

- **macOS**: Creates `.dmg` installer and `.app` bundle
- **Windows**: Creates `.exe` installer and portable version  
- **Linux**: Creates `.AppImage` and `.deb` packages

## 🔒 Security & Privacy

- **No telemetry**: AudioDUPER doesn't collect or transmit any data
- **Local processing**: All analysis happens on your device
- **Secure by design**: Sandboxed renderer with contextual isolation
- **File safety**: Multiple confirmation steps prevent accidental deletion

## ⚠️ Important Notes

- **Backup recommended**: Always backup important files before bulk deletion
- **Large libraries**: Processing thousands of files may take time
- **Memory usage**: Large scans may use significant RAM temporarily
- **False positives**: Review results carefully, especially for live recordings

## 🐛 Troubleshooting

### Common Issues

**"No audio files found"**
- Ensure folder contains supported audio formats
- Check file permissions

**"Fingerprint generation failed"**  
- Install chromaprint system dependencies
- Verify audio files aren't corrupted

**Application won't start**
- Update Node.js to version 16+
- Run `npm install` to reinstall dependencies
- Check console for error messages

### Performance Tips

- **Close other applications** during large scans
- **Use SSD storage** for better performance  
- **Limit concurrent operations** in system settings
- **Process smaller batches** if memory is limited

## 🤝 Contributing

Contributions welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Test your changes thoroughly
4. Submit a pull request with clear description

### Development Guidelines

- Follow existing code style
- Add comments for complex logic
- Test on multiple platforms
- Update documentation as needed

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Chromaprint** - Audio fingerprinting technology
- **Electron** - Cross-platform desktop framework
- **music-metadata** - Audio metadata extraction library
- **Contributors** - Everyone who helps improve AudioDUPER

## 📞 Support

- **Issues**: Report bugs via GitHub Issues
- **Features**: Request features via GitHub Discussions  
- **Documentation**: Check the wiki for detailed guides
- **Community**: Join discussions in GitHub Discussions

---

**Made with ❤️ for music lovers who value organized collections**

*AudioDUPER - Because life's too short for duplicate songs* 🎵