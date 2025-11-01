# Frequently Asked Questions

This FAQ addresses common questions about AudioDUPER, covering installation, usage, troubleshooting, and technical aspects. If you don't find your answer here, please check [TROUBLESHOOTING.md](TROUBLESHOOTING.md) or create an issue on GitHub.

## 🚀 Getting Started

### Q: What is AudioDUPER?

**A:** AudioDUPER is a cross-platform desktop application that identifies duplicate audio files using acoustic fingerprinting technology. Unlike traditional duplicate finders that rely on file names or metadata, AudioDUPER analyzes the actual audio content to find true duplicates regardless of file names, tags, or formats.

### Q: How does AudioDUPER work?

**A:** AudioDUPER uses Chromaprint technology to generate unique acoustic fingerprints for each audio file. These fingerprints are based on the audio content itself, making it possible to identify duplicates even if files have different names, metadata, or formats. The application then groups files with matching fingerprints and helps you safely remove duplicates.

### Q: What platforms does AudioDUPER support?

**A:** AudioDUPER supports:

- **macOS** 10.15+ (Catalina and later)
- **Windows** 10/11 (x64)
- **Linux** (Ubuntu 18.04+, Debian 10+, Fedora 32+, Arch Linux)

### Q: Is AudioDUPER free?

**A:** Yes, AudioDUPER is open-source software released under the MIT license. You can use it, modify it, and distribute it freely.

## 📦 Installation

### Q: How do I install AudioDUPER?

**A:** Installation methods vary by platform:

**macOS:**

- Download the `.dmg` file from GitHub Releases
- Drag AudioDUPER to Applications folder
- Right-click and "Open" on first run (due to Gatekeeper)

**Windows:**

- Download the `.exe` installer from GitHub Releases
- Run the installer and follow the wizard
- Launch from Start Menu or desktop shortcut

**Linux:**

- Download the `.AppImage` file from GitHub Releases
- Make it executable: `chmod +x AudioDUPER.AppImage`
- Run: `./AudioDUPER.AppImage`

### Q: Do I need to install additional dependencies?

**A:** No, AudioDUPER includes all necessary dependencies. The only requirement is the operating system itself. However, on Linux, you may need to install some system libraries if you encounter missing dependency errors.

### Q: Why does macOS say the app is from an unidentified developer?

**A:** This is normal for applications not distributed through the Mac App Store. To resolve:

1. Right-click AudioDUPER and select "Open"
2. Click "Open" in the security dialog
3. This only needs to be done once

### Q: Can I install AudioDUPER for all users?

**A:** Yes, during installation choose the "Install for all users" option (Windows) or drag to Applications folder (macOS). For Linux, system administrators can install the AppImage to `/opt/` and create symlinks.

## 🎵 Audio Formats

### Q: What audio formats does AudioDUPER support?

**A:** AudioDUPER supports a wide range of formats:

- **MP3** (.mp3) - Most common format
- **FLAC** (.flac) - Lossless quality
- **WAV** (.wav) - Uncompressed audio
- **M4A/AAC** (.m4a, .aac) - Apple format
- **OGG Vorbis** (.ogg) - Open source format
- **Opus** (.opus) - Modern efficient format
- **WMA** (.wma) - Windows format

### Q: Can AudioDUPER compare different audio formats?

**A:** Yes! Since AudioDUPER analyzes the audio content itself, it can identify duplicates across different formats. For example, it can detect that a 320kbps MP3 and a FLAC file are the same audio content.

### Q: Does AudioDUPER support high-resolution audio?

**A:** Yes, AudioDUPER can process high-resolution audio files (24-bit, 96kHz, etc.) without issues. The fingerprinting process works with any resolution within the supported formats.

### Q: Can I add support for additional formats?

**A:** AudioDUPER relies on the underlying audio processing libraries. If a format is supported by these libraries, it can be added. For feature requests, please create an issue on GitHub.

## 🔍 Usage

### Q: How do I scan for duplicates?

**A:** Basic scanning is simple:

1. Launch AudioDUPER
2. Click "Select Directory" or drag-and-drop a folder
3. Choose scan options (recursive, file filters)
4. Click "Start Scan"
5. Wait for processing to complete
6. Review results and select files to remove

### Q: How long does a scan take?

**A:** Scan time depends on:

- **Number of files**: More files = longer scan time
- **File sizes**: Larger files take longer to process
- **Hardware speed**: CPU and disk speed affect performance
- **Storage type**: SSD is faster than HDD

Typical performance:

- **100 files**: 1-2 minutes
- **1,000 files**: 10-15 minutes
- **10,000 files**: 1-2 hours

### Q: Can I scan multiple directories at once?

**A:** Currently, AudioDUPER scans one directory at a time, but you can:

- Select a parent directory containing multiple subdirectories
- Use the recursive scan option to include all subdirectories
- Run multiple scans sequentially

### Q: How does AudioDUPER determine which file to keep?

**A:** AudioDUPER uses a quality ranking algorithm:

1. **Bitrate**: Higher bitrate is preferred
2. **Format**: Lossless (FLAC, WAV) > Lossy (MP3, AAC)
3. **File size**: Larger files often indicate higher quality
4. **Modification date**: Newer files might be remastered

You can customize these preferences in settings.

### Q: Can I preview files before deleting?

**A:** Yes, AudioDUPER includes a preview feature:

- Click on any file in the results
- Use the built-in audio player to preview
- Compare files in a duplicate group
- Make informed decisions before deletion

### Q: Does AudioDUPER modify my original files?

**A:** No, AudioDUPER only reads files for analysis. It never modifies original audio files or metadata. When you choose to delete files, they are moved to the system trash/recycle bin, not permanently deleted.

## ⚙️ Settings and Configuration

### Q: Can I customize the quality ranking?

**A:** Yes, AudioDUPER allows you to customize:

- **Format preferences**: Choose which formats you prefer
- **Bitrate weighting**: How important bitrate is in ranking
- **File size consideration**: Include or exclude file size in decisions
- **Date preference**: Prefer newer or older files

### Q: Can I exclude certain files or directories?

**A:** Yes, you can:

- **Exclude file extensions**: Ignore specific file types
- **Exclude directories**: Skip certain folder names
- **Minimum file size**: Ignore very small files
- **Maximum file size**: Skip extremely large files

### Q: Are there keyboard shortcuts?

**A:** Yes, common shortcuts include:

- **Ctrl/Cmd + O**: Open directory
- **Ctrl/Cmd + S**: Start/stop scan
- **Delete**: Remove selected files
- **Ctrl/Cmd + A**: Select all in current group
- **Space**: Play/pause preview
- **Escape**: Cancel current operation

### Q: Can I save scan results?

**A:** Yes, you can:

- **Export results** to CSV or JSON format
- **Save scan sessions** to resume later
- **Generate reports** of duplicate statistics
- **Create exclusion lists** for future scans

## 🔧 Troubleshooting

### Q: AudioDUPER won't start on Windows

**A:** Try these solutions:

1. **Run as administrator**: Right-click and "Run as administrator"
2. **Install Visual C++ Redistributable**: Download from Microsoft
3. **Check Windows Defender**: Add exception for AudioDUPER
4. **Update graphics drivers**: Outdated drivers can cause issues

### Q: AudioDUPER crashes on macOS

**A:** Common solutions:

1. **Allow in Security settings**: System Preferences → Security & Privacy
2. **Reset permissions**: Remove and re-add the app
3. **Check disk space**: Ensure sufficient free space
4. **Update macOS**: Use the latest version

### Q: Scan is very slow on Linux

**A:** Performance tips:

1. **Install missing libraries**: `sudo apt-get install libavcodec-extra`
2. **Use SSD storage**: Faster than traditional HDD
3. **Close other applications**: Free up CPU resources
4. **Exclude system directories**: Don't scan system folders

### Q: "fpcalc not found" error

**A:** This indicates missing audio processing tools:

1. **Reinstall AudioDUPER**: Use the latest version
2. **Install fpcalc manually**: Download from AcoustID website
3. **Check PATH environment**: Ensure fpcalc is in system PATH

### Q: Files are not being detected as duplicates

**A:** Possible reasons:

1. **Different audio content**: Files may sound similar but be different
2. **Low quality recordings**: Poor quality may affect fingerprinting
3. **Very short files**: Files under 10 seconds may not fingerprint well
4. **Corrupted files**: Damaged files can't be processed

## 🔒 Security and Privacy

### Q: Does AudioDUPER send my data anywhere?

**A:** No, AudioDUPER is completely offline:

- All processing happens locally on your computer
- No internet connection required
- No data is sent to any servers
- No telemetry or analytics collection

### Q: Is my audio data safe?

**A:** Yes, AudioDUPER is designed with privacy in mind:

- **Read-only access**: Only reads files for analysis
- **Local processing**: All fingerprinting happens locally
- **No metadata collection**: Doesn't read or store ID3 tags
- **Secure deletion**: Files go to trash, not permanent deletion

### Q: Can AudioDUPER access my entire computer?

**A:** No, AudioDUPER only accesses:

- **Directories you select**: You choose what to scan
- **Files in those directories**: Only reads audio files
- **System trash**: When you choose to delete files

### Q: What about copyrighted material?

**A:** AudioDUPER is a tool for managing personal music collections:

- **Legal use**: Managing files you own
- **No distribution**: Doesn't share or upload files
- **User responsibility**: How you use the tool is up to you
- **Local only**: Everything stays on your computer

## 🚀 Performance

### Q: How can I improve scan speed?

**A:** Performance optimization tips:

1. **Use SSD storage**: Much faster than HDD
2. **Exclude unnecessary files**: Filter out non-audio files
3. **Close other applications**: Free up CPU resources
4. **Scan smaller batches**: Process directories separately
5. **Update to latest version**: Performance improvements in updates

### Q: How much memory does AudioDUPER use?

**A:** Memory usage depends on:

- **Number of files**: More files = more memory
- **File sizes**: Larger files use more memory
- **Scan settings**: Certain options use more memory

Typical usage:

- **Small scans (<100 files)**: 50-100 MB
- **Medium scans (1,000 files)**: 200-500 MB
- **Large scans (10,000+ files)**: 1-2 GB

### Q: Can AudioDUPER handle large music libraries?

**A:** Yes, AudioDUPER can handle large libraries:

- **Tested up to**: 100,000+ files
- **Recommended batch size**: 10,000 files per scan
- **Memory management**: Automatically manages memory usage
- **Progress tracking**: Shows progress for long scans

## 🔧 Advanced Usage

### Q: Can I use AudioDUPER from command line?

**A:** Currently, AudioDUPER is primarily a GUI application, but you can:

- **Drag-and-drop folders**: From command line to the app
- **Use automation tools**: AutoHotkey, AppleScript, etc.
- **Future versions**: May include CLI interface

### Q: Can I integrate AudioDUPER with other tools?

**A:** Integration options:

- **Export results**: CSV/JSON for other tools
- **File watching**: Monitor directories for new duplicates
- **Scripting**: Use exported data in custom scripts
- **API access**: Future versions may provide API

### Q: How accurate is the duplicate detection?

**A:** AudioDUPER's accuracy is very high:

- **True positives**: >99% for identical audio
- **False positives**: <1% (different audio with similar fingerprints)
- **False negatives**: <1% (missed duplicates)
- **Format independence**: Works across all supported formats

### Q: Can AudioDUPER detect near-duplicates?

**A:** Currently, AudioDUPER focuses on exact duplicates:

- **Exact matches**: Same audio content
- **Format differences**: Different formats of same audio
- **Future versions**: May include similarity detection

## 📱 Mobile and Cloud

### Q: Is there a mobile version?

**A:** Currently, AudioDUPER is desktop-only:

- **iOS**: Not available (App Store restrictions)
- **Android**: Not available (technical limitations)
- **Future**: Considering mobile versions

### Q: Can AudioDUPER scan cloud storage?

**A:** It depends on the cloud service:

- **Local sync folders**: Yes (Google Drive, Dropbox, OneDrive)
- **Direct cloud access**: No (requires internet connection)
- **Workaround**: Sync cloud folders locally, then scan

### Q: What about network-attached storage (NAS)?

**A:** Yes, AudioDUPER can scan NAS:

- **Mapped drives**: Works with mapped network drives
- **UNC paths**: Supports network paths (Windows)
- **Performance**: Slower than local storage
- **Recommendation**: Copy files locally for best performance

## 🆘 Getting Help

### Q: Where can I get support?

**A:** Support options:

- **GitHub Issues**: Report bugs and request features
- **GitHub Discussions**: Community help and discussion
- **Documentation**: Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
- **FAQ**: This document for common questions

### Q: How do I report a bug?

**A:** Bug reporting guidelines:

1. **Search existing issues**: Check if already reported
2. **Use bug report template**: Fill out all sections
3. **Include system info**: OS, version, hardware
4. **Provide steps to reproduce**: Detailed reproduction steps
5. **Add screenshots**: If applicable, include screenshots

### Q: How do I request a feature?

**A:** Feature request process:

1. **Check roadmap**: See if already planned
2. **Search existing requests**: Avoid duplicates
3. **Use feature request template**: Provide detailed proposal
4. **Explain use case**: Why the feature is needed
5. **Consider implementation**: Any technical suggestions

### Q: Can I contribute to AudioDUPER?

**A:** Yes! Contributions are welcome:

- **Code contributions**: Fix bugs, add features
- **Documentation**: Improve docs, fix typos
- **Testing**: Report bugs, test new versions
- **Translations**: Help with localization
- **Design**: UI/UX improvements

See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

---

## 📚 Additional Resources

- **[Quick Start Guide](QUICK_START.md)**: Comprehensive usage documentation
- **[Troubleshooting](TROUBLESHOOTING.md)**: Detailed problem-solving guide
- **[Installation Guide](INSTALLATION.md)**: Step-by-step installation instructions
- **[Development Documentation](DEVELOPMENT.md)**: For contributors and developers
- **[GitHub Repository](https://github.com/your-username/audio-duper)**: Source code and issues

---

_Last updated: October 31, 2025_

_If you have a question not answered here, please check the documentation or create an issue on GitHub._
