# 📥 Installation Guide

This guide covers installing AudioDUPER on all supported platforms, including system requirements, installation methods, and troubleshooting.

## Table of Contents

- [System Requirements](#system-requirements)
- [Installation Methods](#installation-methods)
- [Platform-Specific Installation](#platform-specific-installation)
- [Verification](#verification)
- [Troubleshooting](#troubleshooting)
- [Uninstallation](#uninstallation)

## System Requirements

### Minimum Requirements

#### All Platforms

- **RAM**: 4GB minimum (8GB recommended)
- **Storage**: 100MB free space + space for audio files
- **Display**: 1024x768 minimum (1280x720 recommended)

#### macOS

- **OS Version**: macOS 10.15 (Catalina) or later
- **Architecture**: Intel (x64) or Apple Silicon (M1/M2/M3)
- **Permissions**: Full disk access for music folders

#### Windows

- **OS Version**: Windows 10 (version 1903) or later
- **Architecture**: x64 or x86 (ia32)
- **Components**: .NET Desktop Runtime 6.0+ (auto-installed)

#### Linux

- **Distribution**: Ubuntu 18.04+, Fedora 30+, Arch Linux, or equivalent
- **Architecture**: x64 or ARM64
- **Libraries**: GTK+ 3.0, libnotify, libnss3

### Recommended Requirements

#### For Large Libraries (10,000+ files)

- **RAM**: 16GB or more
- **CPU**: Multi-core processor (4+ cores)
- **Storage**: SSD storage for better performance
- **Network**: Stable internet for updates (optional)

#### Audio Processing Performance

- **CPU**: Modern processor with AES-N support
- **RAM**: 8GB+ for parallel processing
- **Storage**: Fast storage (SSD > HDD)
- **Cache**: Additional space for temporary files

## Installation Methods

### Method 1: Direct Download (Recommended)

#### Step 1: Download

1. Visit [GitHub Releases](https://github.com/sanchez314c/audio-duper/releases)
2. Select your platform
3. Download the latest stable release

#### Step 2: Install

- **macOS**: Open DMG and drag to Applications
- **Windows**: Run EXE installer and follow prompts
- **Linux**: Make AppImage executable and run

### Method 2: Package Manager

#### Homebrew (macOS)

```bash
# Install
brew install --cask audioduper

# Update
brew upgrade --cask audioduper

# Uninstall
brew uninstall --cask audioduper
```

#### Chocolatey (Windows)

```bash
# Install
choco install audioduper

# Update
choco upgrade audioduper

# Uninstall
choco uninstall audioduper
```

#### Snap (Linux)

```bash
# Install
sudo snap install audioduper

# Update
sudo snap refresh audioduper

# Uninstall
sudo snap remove audioduper
```

### Method 3: Source Installation

#### Prerequisites

```bash
# Install Node.js (if not installed)
# macOS
brew install node

# Windows
# Download from https://nodejs.org/

# Linux
sudo apt install nodejs npm  # Ubuntu/Debian
sudo dnf install nodejs npm  # Fedora
sudo pacman -S nodejs npm  # Arch
```

#### Installation Steps

```bash
# Clone repository
git clone https://github.com/sanchez314c/audio-duper.git
cd audio-duper

# Install dependencies
npm install

# Run in development mode
npm run dev

# Build for production
npm run build
```

## Platform-Specific Installation

### macOS Installation

#### Standard Installation

1. **Download DMG**
   - Get `AudioDUPER-1.0.0.dmg` from releases
   - Verify SHA256 checksum if provided

2. **Open DMG**
   - Double-click the DMG file
   - Verify the signature (Ctrl+click, Open)

3. **Install Application**
   - Drag AudioDUPER.app to Applications folder
   - Wait for copy to complete

4. **First Launch**
   - Open Launchpad and click AudioDUPER
   - Grant necessary permissions when prompted

#### Security Permissions

macOS may require permission grants:

1. **Gatekeeper**

   ```
   Right-click app → Open
   Click "Open" in security dialog
   ```

2. **Full Disk Access**

   ```
   System Preferences → Security & Privacy → Privacy → Full Disk Access
   Add AudioDUPER.app
   ```

3. **Accessibility** (if using screen reader)
   ```
   System Preferences → Security & Privacy → Privacy → Accessibility
   Add AudioDUPER.app
   ```

#### Command Line Installation

```bash
# Using Homebrew Cask
brew install --cask audioduper

# Manual installation
sudo cp -R AudioDUPER.app /Applications/
sudo xattr -dr com.apple.quarantine /Applications/AudioDUPER.app
```

### Windows Installation

#### Standard Installation

1. **Download Installer**
   - Get `AudioDUPER-Setup-1.0.0.exe` from releases
   - Verify digital signature

2. **Run Installer**
   - Right-click → "Run as administrator"
   - Follow installation wizard
   - Choose installation directory

3. **Complete Setup**
   - Launch from Start Menu
   - Allow Windows Defender access

#### Security Configuration

1. **Windows Defender**

   ```
   Windows Security → Virus & threat protection
   Add exclusion for AudioDUPER folder
   ```

2. **SmartScreen**

   ```
   Click "More info" on SmartScreen warning
   Click "Run anyway"
   ```

3. **Firewall**
   ```
   Windows Security → Firewall
   Allow AudioDUPER through firewall
   ```

#### Portable Installation

```bash
# Download portable version
# AudioDUPER-1.0.0-win-portable.zip

# Extract and run
unzip AudioDUPER-1.0.0-win-portable.zip
cd AudioDUPER-win-portable
AudioDUPER.exe
```

### Linux Installation

#### AppImage (Universal)

```bash
# Download AppImage
wget https://github.com/sanchez314c/audio-duper/releases/download/v1.0.0/AudioDUPER-1.0.0.AppImage

# Make executable
chmod +x AudioDUPER-1.0.0.AppImage

# Run
./AudioDUPER-1.0.0.AppImage
```

#### DEB Package (Debian/Ubuntu)

```bash
# Download DEB
wget https://github.com/sanchez314c/audio-duper/releases/download/v1.0.0/audioduper_1.0.0_amd64.deb

# Install
sudo dpkg -i audioduper_1.0.0_amd64.deb

# Fix dependencies if needed
sudo apt-get install -f
```

#### RPM Package (Red Hat/Fedora)

```bash
# Download RPM
wget https://github.com/sanchez314c/audio-duper/releases/download/v1.0.0/audioduper-1.0.0-1.x86_64.rpm

# Install
sudo rpm -i audioduper-1.0.0-1.x86_64.rpm

# Update
sudo rpm -U audioduper-1.0.0-1.x86_64.rpm
```

#### Flatpak (Universal)

```bash
# Install from Flathub
flatpak install flathub com.audiodedupe.app

# Run
flatpak run com.audiodedupe.app
```

## Verification

### Verify Installation

#### Check Application Version

1. **In Application**
   - Help → About AudioDUPER
   - Version should match download

2. **Command Line**

   ```bash
   # macOS/Linux
   /Applications/AudioDUPER.app/Contents/MacOS/AudioDUPER --version

   # Windows
   "C:\Program Files\AudioDUPER\AudioDUPER.exe" --version
   ```

#### Verify Functionality

1. **Launch Application**
   - Should open without errors
   - UI should display correctly

2. **Test Basic Features**
   - Select a folder with audio files
   - Run a scan
   - Verify results display

3. **Check Permissions**
   - Should be able to access music folders
   - No permission errors in logs

#### Verify Integrity

```bash
# macOS: Verify code signature
codesign --verify --verbose /Applications/AudioDUPER.app

# Windows: Verify digital signature
signtool verify /pa /v "C:\Program Files\AudioDUPER\AudioDUPER.exe"

# Linux: Verify checksum
sha256sum AudioDUPER-1.0.0.AppImage
# Compare with release checksum
```

## Troubleshooting

### Common Installation Issues

#### macOS Issues

**"AudioDUPER can't be opened because Apple cannot check it for malicious software"**

```bash
# Solution 1: Allow via System Preferences
System Preferences → Security & Privacy → General
Click "Open Anyway" for AudioDUPER

# Solution 2: Remove quarantine attribute
sudo xattr -dr com.apple.quarantine /Applications/AudioDUPER.app
```

**"Application is damaged and can't be opened"**

```bash
# Re-download the DMG
# Verify checksum before opening
# Try alternative download method
```

**"Full disk access required"**

```
System Preferences → Security & Privacy → Privacy → Full Disk Access
Click the lock icon (requires admin password)
Check the box next to AudioDUPER
Restart the application
```

#### Windows Issues

**"Windows protected your PC"**

```
Click "More info"
Click "Run anyway"
Or add exclusion in Windows Security
```

**"The application cannot be started"**

```bash
# Install Visual C++ Redistributable
# Download from Microsoft website
# Install and restart computer
```

**"Code signing error"**

```
Verify the download source
Check the digital signature
Download from official GitHub releases only
```

#### Linux Issues

**"Permission denied"**

```bash
# Make executable
chmod +x AudioDUPER.AppImage

# Or run with explicit permissions
sudo ./AudioDUPER.AppImage
```

**"Missing dependencies"**

```bash
# Ubuntu/Debian
sudo apt-get install libgtk-3-0 libnotify4 libnss3 libxss1

# Fedora
sudo dnf install gtk3 libnotify libnss3 libXScrnSaver

# Arch Linux
sudo pacman -S gtk3 libnotify nss
```

**"AppImage won't launch"**

```bash
# Extract and run
./AudioDUPER.AppImage --appimage-extract-and-run

# Or try FUSE module
sudo apt-get install libfuse2
```

### Performance Issues

#### Slow Scanning

1. **Check available RAM**
   - Close other applications
   - Monitor memory usage

2. **Verify storage speed**
   - SSD preferred over HDD
   - Check disk health

3. **Optimize settings**
   - Process smaller batches
   - Exclude system folders

#### High Memory Usage

1. **Restart application**
   - Clear memory cache
   - Start fresh scan

2. **Adjust settings**
   - Reduce parallel processing
   - Limit file cache size

## Uninstallation

### macOS Uninstallation

```bash
# Method 1: Drag to Trash
Drag AudioDUPER.app from Applications to Trash

# Method 2: Command line
sudo rm -rf /Applications/AudioDUPER.app

# Remove preferences
rm ~/Library/Preferences/com.audiodedupe.app.plist
```

### Windows Uninstallation

```bash
# Method 1: Control Panel
Settings → Apps & features → AudioDUPER → Uninstall

# Method 2: Start Menu
Start Menu → AudioDUPER → Uninstall
```

### Linux Uninstallation

```bash
# AppImage
rm AudioDUPER.AppImage

# DEB package
sudo dpkg -r audioduper

# RPM package
sudo rpm -e audioduper

# Flatpak
flatpak uninstall com.audiodedupe.app
```

### Clean Up

#### Remove User Data (Optional)

```bash
# macOS
rm ~/Library/Application\ Support/AudioDUPER
rm ~/Library/Caches/com.audiodedupe.app

# Windows
rmdir /s "%APPDATA%\AudioDUPER"
rmdir /s "%LOCALAPPDATA%\AudioDUPER"

# Linux
rm ~/.config/audioduper
rm ~/.cache/audioduper
```

## Getting Help

### Support Resources

1. **Documentation**: [docs/](../docs/) folder
2. **FAQ**: [FAQ.md](FAQ.md)
3. **Issues**: [GitHub Issues](https://github.com/sanchez314c/audio-duper/issues)
4. **Discussions**: [GitHub Discussions](https://github.com/sanchez314c/audio-duper/discussions)

### Reporting Installation Issues

When reporting issues, include:

- **Operating System**: Version and architecture
- **Installation Method**: DMG, EXE, AppImage, etc.
- **Error Messages**: Exact text of any errors
- **Steps Taken**: What you tried and results

### Community Support

- **GitHub**: Create issue or discussion
- **Email**: `sanchez314c@jasonpaulmichaels.co`
- **Discord**: (future) Community Discord server

---

## Installation Quick Reference

| Platform | File Type  | Installation Command                |
| -------- | ---------- | ----------------------------------- |
| macOS    | DMG        | Open and drag to Applications       |
| Windows  | EXE        | Run installer as administrator      |
| Linux    | AppImage   | `chmod +x && ./AudioDUPER.AppImage` |
| macOS    | Homebrew   | `brew install --cask audioduper`    |
| Windows  | Chocolatey | `choco install audioduper`          |
| Linux    | Snap       | `sudo snap install audioduper`      |

---

_For the most up-to-date installation instructions, visit the [GitHub Releases page](https://github.com/sanchez314c/audio-duper/releases)._
