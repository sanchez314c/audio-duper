# Troubleshooting Guide

This comprehensive troubleshooting guide helps you resolve common issues with AudioDUPER. Problems are organized by category with step-by-step solutions and preventive measures.

## 🔧 Quick Diagnostics

### Before Troubleshooting

#### System Information Check

First, gather information about your system:

**macOS**

```bash
# System information
sw_vers
system_profiler SPHardwareDataType

# Available disk space
df -h

# Memory usage
vm_stat
```

**Windows**

```cmd
# System information
systeminfo
wmic cpu get name
wmic diskdrive get size,model

# Available disk space
wmic logicaldisk get size,freespace,caption
```

**Linux**

```bash
# System information
uname -a
lscpu
df -h

# Memory usage
free -h
```

#### AudioDUPER Diagnostics

Check AudioDUPER's internal state:

1. **Open Developer Tools** (if available)
2. **Check Console** for error messages
3. **Review Settings** for configuration issues
4. **Test with Small Directory** to isolate the problem

## 🚀 Installation Issues

### "Application won't open"

#### macOS

**Symptoms**: Double-clicking AudioDUPER does nothing or shows error

**Solutions**:

1. **Gatekeeper Bypass**:

   ```bash
   # Right-click app → Open → Open
   # Or allow in System Preferences
   ```

2. **Check Permissions**:
   - System Preferences → Security & Privacy
   - Allow AudioDUPER in "App Store and Identified Developers"
   - Grant file access permissions

3. **Reinstall**:

   ```bash
   # Remove existing app
   rm -rf /Applications/AudioDUPER.app

   # Download fresh copy and reinstall
   ```

4. **Check macOS Version**:
   - Requires macOS 10.15+ (Catalina)
   - Update if using older version

#### Windows

**Symptoms**: Nothing happens when launching, or error about unknown publisher

**Solutions**:

1. **Run as Administrator**:
   - Right-click AudioDUPER.exe
   - "Run as administrator"

2. **Windows Defender Exclusion**:
   - Windows Security → Virus & threat protection
   - Manage settings → Add or remove exclusions
   - Add AudioDUPER folder and executable

3. **Install Visual C++ Redistributable**:
   - Download from Microsoft website
   - Install both x86 and x64 versions

4. **Check Windows Version**:
   - Requires Windows 10 or 11
   - Update Windows if needed

#### Linux

**Symptoms**: Permission denied, missing dependencies, or won't launch

**Solutions**:

1. **Make Executable**:

   ```bash
   chmod +x AudioDUPER.AppImage
   ```

2. **Install Missing Dependencies**:

   ```bash
   # Ubuntu/Debian
   sudo apt-get install libgtk-3-0 libxss1 libasound2

   # Fedora
   sudo dnf install gtk3 libXScrnSaver alsa-lib

   # Arch Linux
   sudo pacman -S gtk3 libxss alsa-lib
   ```

3. **Run with Correct User**:

   ```bash
   # Don't run as root unless necessary
   ./AudioDUPER.AppImage
   ```

4. **Check glibc Version**:
   ```bash
   ldd --version
   # Requires glibc 2.17+
   ```

### "Installer fails"

#### Common Causes and Solutions

**Insufficient Permissions**:

- **Windows**: Right-click installer → "Run as administrator"
- **macOS**: Ensure admin password when prompted
- **Linux**: Use `sudo` if required

**Corrupted Download**:

- **Redownload** the installer
- **Verify checksum** if provided
- **Use different browser** for download

**Antivirus Interference**:

- **Temporarily disable** antivirus during installation
- **Add exception** for AudioDUPER installer
- **Re-enable** after installation

**Insufficient Disk Space**:

- **Free up space** on target drive
- **Choose different installation location**
- **Clean temporary files** before installing

## 🎵 Audio Processing Issues

### "No duplicates found" (but you expect some)

#### Common Causes

**Different Audio Content**:

- Files may sound similar but be different mixes/versions
- Check if files are actually identical
- Listen to files to confirm they're duplicates

**Format-Specific Issues**:

```bash
# Test with specific format
# Try scanning only MP3 files first
# Then try other formats separately
```

**File Corruption**:

- Check if files can be played in other players
- Try repairing corrupted files
- Exclude corrupted files from scan

**Very Short Files**:

- Files under 10 seconds may not fingerprint well
- AudioDUPER might skip very short audio
- Check minimum file size settings

#### Diagnostic Steps

1. **Scan Small Subset**: Test with 10-20 known duplicates
2. **Check File Formats**: Ensure formats are supported
3. **Verify File Integrity**: Play files in media player
4. **Review Settings**: Check exclusion rules and filters

### "Scan is very slow"

#### Performance Optimization

**System Resources**:

- **Close other applications** while scanning
- **Check CPU usage** in Task Manager/Activity Monitor
- **Ensure sufficient RAM** is available

**Storage Type**:

- **SSD vs HDD**: SSDs are significantly faster
- **External Drives**: USB drives are slower than internal
- **Network Storage**: NAS drives add network latency

**File Characteristics**:

- **Large Files**: Take longer to process
- **High Bitrate**: More data to analyze
- **Many Files**: More processing required

#### Optimization Steps

1. **Use SSD Storage**: Copy files to SSD for scanning
2. **Process in Batches**: Scan 5,000 files at a time
3. **Exclude Unnecessary Files**: Filter out non-audio files
4. **Update AudioDUPER**: Use latest version with optimizations

```bash
# Monitor system resources during scan
# macOS
top -o cpu -pid $(pgrep AudioDUPER)

# Windows
Get-Process | Where-Object {$_.ProcessName -eq "AudioDUPER"}

# Linux
top -p $(pgrep -f AudioDUPER)
```

### "fpcalc not found" or "Audio processing failed"

#### Missing Dependencies

**Install fpcalc Manually**:

```bash
# macOS
brew install chromaprint

# Ubuntu/Debian
sudo apt-get install chromaprint-tools

# Fedora
sudo dnf install chromaprint-tools

# Windows (using Chocolatey)
choco install chromaprint

# Or download from: https://acoustid.org/chromaprint
```

**Verify Installation**:

```bash
# Test fpcalc command
fpcalc -version

# Test with sample file
fpcalc /path/to/audio.mp3
```

**PATH Issues**:

```bash
# Check if fpcalc is in PATH
which fpcalc

# Add to PATH if needed
export PATH=$PATH:/usr/local/bin  # Linux/macOS
# Or add to Windows Environment Variables
```

#### Audio Codec Issues

**Missing Codecs**:

```bash
# Install additional codecs
# macOS
brew install ffmpeg

# Ubuntu/Debian
sudo apt-get install ffmpeg libavcodec-extra

# Fedora
sudo dnf install ffmpeg
```

**Test Audio Decoding**:

```bash
# Test with ffmpeg
ffmpeg -i /path/to/problematic.mp3 -f null -
```

## 🖥 User Interface Issues

### "Application window is blank/white"

#### Graphics Driver Issues

**Update Graphics Drivers**:

- **Windows**: Update via Device Manager or manufacturer website
- **macOS**: Update via Software Update
- **Linux**: Update via distribution package manager

**Disable Hardware Acceleration**:

```javascript
// In main.js, add these flags
app.commandLine.appendSwitch('disable-gpu');
app.commandLine.appendSwitch('disable-software-rasterizer');
```

**Try Different Rendering**:

```javascript
// Force software rendering
app.disableHardwareAcceleration();
```

### "UI is unresponsive or frozen"

#### Memory Issues

**Check Memory Usage**:

```bash
# macOS
Activity Monitor → Memory tab

# Windows
Task Manager → Performance tab

# Linux
top -o mem
```

**Solutions**:

1. **Close Other Applications**: Free up system memory
2. **Scan Smaller Batches**: Process fewer files at once
3. **Restart Application**: Clear memory leaks
4. **Check for Memory Leaks**: Monitor memory growth over time

#### CPU Overload

**Symptoms**: UI freezes during scanning, high CPU usage

**Solutions**:

1. **Lower Scan Priority**: In settings, reduce CPU usage
2. **Use Fewer Worker Threads**: Limit parallel processing
3. **Exclude Large Files**: Skip very large audio files
4. **Update Application**: Latest versions may have optimizations

### "Text is garbled or UI elements missing"

#### Font and Rendering Issues

**Font Problems**:

- **macOS**: Check if fonts are installed in Font Book
- **Windows**: Verify fonts in C:\Windows\Fonts
- **Linux**: Install fonts via package manager or manually

**Scaling Issues**:

- **Windows**: Check display scaling in Settings
- **macOS**: Adjust in System Preferences
- **Linux**: Configure in desktop environment settings

**Solutions**:

1. **Restart Application**: Clear rendering cache
2. **Reset Settings**: Delete configuration file
3. **Update Graphics Drivers**: Latest drivers fix rendering issues
4. **Try Different Theme**: Switch between light/dark themes

## 💾 File System Issues

### "Permission denied" errors

#### File Access Problems

**macOS Permissions**:

1. **System Preferences → Security & Privacy**
2. **Privacy tab → Files and Folders**
3. **Grant AudioDUPER access** to target directories
4. **Restart AudioDUPER** after granting permissions

**Windows Permissions**:

1. **Right-click folder → Properties**
2. **Security tab → Edit**
3. **Add your user account** with full control
4. **Apply to all subfolders and files**

**Linux Permissions**:

```bash
# Check file permissions
ls -la /path/to/music

# Fix permissions if needed
sudo chown -R $USER:$USER /path/to/music
sudo chmod -R 755 /path/to/music
```

#### Antivirus Interference

**Exclude AudioDUPER**:

- **Windows Defender**: Add folder exclusions
- **Third-party AV**: Add AudioDUPER to safe list
- **Corporate AV**: Contact IT department

**Test Without AV**:

- Temporarily disable antivirus
- Test AudioDUPER functionality
- Re-enable antivirus and add exclusions

### "Files are not being deleted"

#### Trash/Recycle Bin Issues

**macOS Trash**:

```bash
# Check trash permissions
ls -la ~/.Trash/

# Empty trash if full
rm -rf ~/.Trash/*
```

**Windows Recycle Bin**:

- Check if Recycle Bin is full
- Empty Recycle Bin
- Check user permissions for Recycle Bin

**Linux Trash**:

```bash
# Check trash
ls -la ~/.local/share/Trash/

# Empty if needed
rm -rf ~/.local/share/Trash/*
```

#### File Lock Issues

**Applications Locking Files**:

- Close media players (iTunes, Spotify, etc.)
- Close file sync applications (Dropbox, OneDrive)
- Close audio editing software

**Check File Handles**:

```bash
# macOS
lsof | grep /path/to/file

# Windows
handle.exe /path/to/file

# Linux
lsof /path/to/file
```

## 🔒 Security Issues

### "Application is blocked by security software"

#### Firewall Issues

**Windows Firewall**:

1. **Windows Security → Firewall & network protection**
2. **Allow an app through firewall**
3. **Add AudioDUPER** with both private and public network access

**macOS Firewall**:

1. **System Preferences → Security & Privacy**
2. **Firewall tab**
3. **Firewall Options** and add AudioDUPER

**Linux Firewall**:

```bash
# UFW (Ubuntu)
sudo ufw allow AudioDUPER

# firewalld (Fedora)
sudo firewall-cmd --add-application=AudioDUPER
```

#### Corporate Security

**IT Department Approval**:

- Request software approval
- Explain business need for duplicate detection
- Provide security documentation
- Suggest trial in test environment

**Alternative Solutions**:

- Use portable version if available
- Run from user directory without installation
- Use web-based alternatives if approved

## 🌐 Network and Cloud Issues

### "Can't scan cloud storage folders"

#### Cloud Sync Limitations

**Dropbox/OneDrive/Google Drive**:

- Files may be partially downloaded
- Smart sync might cause issues
- Network latency affects performance

**Solutions**:

1. **Make Files Available Offline**:
   - Right-click folder → "Make available offline"
   - Wait for sync to complete
   - Try scanning again

2. **Use Local Copy**:
   - Copy cloud folder to local storage
   - Scan local copy
   - Manually manage duplicates

3. **Exclude Cloud Folders**:
   - Add cloud folders to exclusion list
   - Focus on local music files

#### Network Storage (NAS) Issues

**Connection Problems**:

- Verify network connectivity
- Check NAS credentials and permissions
- Test with other applications

**Performance Issues**:

- Use wired connection instead of Wi-Fi
- Scan during off-peak hours
- Process smaller batches

**Solutions**:

```bash
# Mount NAS with proper options
# macOS
mount -t smbfs //server/share /mnt/nas

# Linux
mount -t cifs //server/share /mnt/nas -o username=user,password=pass
```

## 📊 Performance Issues

### "High memory usage"

#### Memory Optimization

**Monitor Memory Usage**:

```javascript
// Add memory monitoring to main.js
setInterval(() => {
  const usage = process.memoryUsage();
  console.log(`Memory: ${Math.round(usage.rss / 1024 / 1024)}MB`);
}, 5000);
```

**Optimization Steps**:

1. **Reduce Cache Size**: In settings, limit fingerprint cache
2. **Process Smaller Batches**: Scan fewer files at once
3. **Close Other Applications**: Free up system memory
4. **Restart Application**: Clear memory leaks

**Memory Leak Detection**:

- Monitor memory usage over time
- If memory continuously increases, report bug
- Use memory profiling tools if available

### "High CPU usage"

#### CPU Optimization

**Identify CPU-Intensive Operations**:

- Audio fingerprinting is CPU-intensive
- Multiple parallel processing increases usage
- Large files require more processing

**Optimization Steps**:

1. **Adjust Worker Threads**: Reduce parallel processing
2. **Exclude Large Files**: Skip files above size threshold
3. **Use Power Saver Mode**: In settings, enable power saving
4. **Schedule Scans**: Run during off-hours

**CPU Monitoring**:

```bash
# Continuous CPU monitoring
# macOS
top -o cpu -s 5 -n 0

# Windows
Get-Counter '\Processor(_Total)\% Processor Time' -SampleInterval 5

# Linux
top -b -d 5
```

## 🐛 Advanced Troubleshooting

### Debug Mode

#### Enable Debug Logging

**macOS/Linux**:

```bash
# Run with debug environment
DEBUG=* /Applications/AudioDUPER.app/Contents/MacOS/AudioDUPER
```

**Windows**:

```cmd
# Set environment variable and run
set DEBUG=*
"C:\Program Files\AudioDUPER\AudioDUPER.exe"
```

**Log Locations**:

- **macOS**: ~/Library/Logs/AudioDUPER/
- **Windows**: %APPDATA%/AudioDUPER/logs/
- **Linux**: ~/.local/share/AudioDUPER/logs/

#### Generate Diagnostic Report

**Manual Diagnostics**:

```bash
# Create diagnostic bundle
mkdir ~/AudioDUPER-Diagnostics
cd ~/AudioDUPER-Diagnostics

# System information
systeminfo > system.txt 2>&1  # Windows
system_profiler > system.txt 2>&1  # macOS

# AudioDUPER logs
cp -r ~/Library/Logs/AudioDUPER/* ./logs  # macOS
cp -r %APPDATA%/AudioDUPER/logs/* ./logs  # Windows

# Configuration files
cp -r ~/.config/AudioDUPER/* ./config  # Linux
```

**Automatic Diagnostics**:

1. **Help → Generate Diagnostics** in AudioDUPER
2. **Save diagnostic file** to desktop
3. **Attach to bug report** or support request

### Clean Reinstallation

#### Backup Settings

```bash
# Export settings before reinstall
# macOS
cp ~/Library/Preferences/com.audioduper.plist ~/Desktop/

# Windows
copy "%APPDATA%\AudioDUPER\settings.json" %USERPROFILE%\Desktop\

# Linux
cp ~/.config/AudioDUPER/settings.json ~/Desktop/
```

#### Complete Removal

```bash
# macOS
rm -rf /Applications/AudioDUPER.app
rm -rf ~/Library/Preferences/com.audioduper.plist
rm -rf ~/Library/Application\ Support/AudioDUPER
rm -rf ~/Library/Caches/AudioDUPER

# Windows
rmdir /s /q "C:\Program Files\AudioDUPER"
rmdir /s /q "%APPDATA%\AudioDUPER"
rmdir /s /q "%LOCALAPPDATA%\AudioDUPER"

# Linux
rm -rf /opt/AudioDUPER
rm -rf ~/.config/AudioDUPER
rm -rf ~/.local/share/AudioDUPER
```

#### Fresh Installation

1. **Download latest version** from GitHub
2. **Verify download integrity** with checksum
3. **Install using standard procedure**
4. **Restore settings** from backup
5. **Test functionality** before importing data

## 📞 Getting Help

### When to Contact Support

**Self-Service First**:

1. **Check this guide** for your issue
2. **Search [FAQ](FAQ.md)** for quick answers
3. **Check [GitHub Issues](https://github.com/your-username/audio-duper/issues)** for existing reports

**Contact Support When**:

- Issue not documented in troubleshooting guide
- Multiple attempts to resolve have failed
- Error messages are unclear or suggest bugs
- Performance is significantly worse than expected

### Information to Include

**Bug Reports**:

1. **AudioDUPER Version**: Help → About
2. **Operating System**: Version and build number
3. **Hardware Specs**: CPU, RAM, storage type
4. **Error Message**: Exact text of any error
5. **Steps to Reproduce**: Detailed reproduction steps
6. **Expected vs Actual**: What you expected vs what happened
7. **Additional Context**: Anything else relevant

**Performance Issues**:

1. **Library Size**: Number of files and total size
2. **Scan Time**: How long the scan took
3. **System Resources**: CPU and memory usage during scan
4. **Network Storage**: Whether scanning network drives
5. **Comparison**: How performance compares to expectations

### Support Channels

**GitHub Issues**:

- **Bug Reports**: [https://github.com/your-username/audio-duper/issues](https://github.com/your-username/audio-duper/issues)
- **Feature Requests**: [https://github.com/your-username/audio-duper/issues](https://github.com/your-username/audio-duper/issues)
- **Security Issues**: security@audioduper.com

**Community Support**:

- **GitHub Discussions**: [https://github.com/your-username/audio-duper/discussions](https://github.com/your-username/audio-duper/discussions)
- **Community Forum**: (if available)
- **Reddit**: r/audioduper (if available)

---

## 📚 Preventive Measures

### Regular Maintenance

**System Maintenance**:

- Keep operating system updated
- Update graphics drivers regularly
- Run disk cleanup utilities
- Monitor system health

**Application Maintenance**:

- Keep AudioDUPER updated to latest version
- Clear cache periodically if it grows large
- Backup settings before major updates
- Review and update exclusion rules

### Best Practices

**File Organization**:

- Use consistent file naming conventions
- Organize files in logical folder structure
- Avoid duplicate downloads from different sources
- Regular library cleanup

**Scanning Practices**:

- Scan reasonable batch sizes
- Exclude system and temporary directories
- Use appropriate quality settings
- Review results before deleting files

---

_Last updated: October 31, 2025_

_If this guide doesn't resolve your issue, please create an issue on GitHub with detailed information about your problem._
