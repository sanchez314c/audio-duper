# Quick Start Guide

Get AudioDUPER up and running in 5 minutes! This guide will help you install the application, perform your first scan, and start managing duplicate audio files.

## 🚀 Installation

### Option 1: Download Pre-built Binary (Recommended)

#### macOS

1. **Download**: Get the latest `.dmg` file from [GitHub Releases](https://github.com/sanchez314c/audio-duper/releases)
2. **Open**: Double-click the downloaded `.dmg` file
3. **Install**: Drag AudioDUPER to your Applications folder
4. **Launch**: Open Applications folder, double-click AudioDUPER
5. **Allow**: If you see a security warning, right-click → "Open" → "Open"

#### Windows

1. **Download**: Get the latest `.exe` installer from [GitHub Releases](https://github.com/sanchez314c/audio-duper/releases)
2. **Run**: Double-click the downloaded installer
3. **Follow**: Click through the installation wizard
4. **Launch**: AudioDUPER will be in your Start Menu
5. **Allow**: If Windows Defender prompts, click "More info" → "Run anyway"

#### Linux

1. **Download**: Get the latest `.AppImage` file from [GitHub Releases](https://github.com/sanchez314c/audio-duper/releases)
2. **Make Executable**: Open terminal and run `chmod +x AudioDUPER.AppImage`
3. **Run**: Double-click the file or run `./AudioDUPER.AppImage` in terminal

### Option 2: Build from Source

For developers or advanced users who want the latest features:

```bash
# Clone repository
git clone https://github.com/sanchez314c/audio-duper.git
cd audio-duper

# Install dependencies
npm install

# Run in development mode
npm run dev

# Or build for production
npm run build
npm start
```

## 🎵 Your First Scan

### Step 1: Launch AudioDUPER

Open the application from your Applications folder, Start Menu, or terminal.

### Step 2: Select Directory

1. **Click** the "Select Directory" button, OR
2. **Drag and drop** a folder onto the application window

**Good starting points**:

- Your Music folder (`~/Music` on macOS, `C:\Users\YourName\Music` on Windows)
- Downloads folder where you save music files
- External drives with music collections

### Step 3: Start Scanning

Click the "Start Scan" button and wait for processing to complete.

**What happens during scanning**:

- AudioDUPER analyzes each file's acoustic content
- Generates unique fingerprints for comparison
- Groups files with matching fingerprints
- Shows real-time progress

### Step 4: Review Results

Once scanning completes, you'll see:

- **Duplicate Groups**: Each group contains identical audio files
- **Quality Indicators**: Visual cues showing which files are higher quality
- **File Details**: Format, bitrate, size, and path information

## 🎯 Managing Duplicates

### Understanding Quality Indicators

AudioDUPER uses a smart algorithm to rank file quality:

**🟢 High Quality** (Recommended to keep)

- Lossless formats (FLAC, WAV)
- High bitrate (320kbps+ for MP3)
- Larger file sizes

**🟡 Medium Quality** (Acceptable)

- Standard bitrate (192-256kbps for MP3)
- Compressed lossless formats
- Medium file sizes

**🔴 Low Quality** (Consider removing)

- Low bitrate (<128kbps for MP3)
- Highly compressed formats
- Small file sizes

### Making Decisions

#### Option 1: Manual Selection

1. **Click** on files to preview them (play button appears)
2. **Listen** to compare audio quality
3. **Select** the files you want to remove
4. **Click** "Remove Selected" to delete them

#### Option 2: Keep All

If you're unsure or want to decide later:

1. **Click** "Keep All" to skip this group
2. **Return** later to review again

### Safety Notes

**Warning**: Deleted files are permanently removed using `fs.unlink()`. They do NOT go to the system trash. Make sure you have backups of important files before deleting.

**If you make a mistake**: Check your backups or file recovery tools. There is no built-in undo for deletions.

## ⚙️ Settings

_A settings/preferences UI is planned for v1.1. Currently, AudioDUPER uses built-in defaults for quality ranking and scan behavior._

## 📊 Understanding Results

### Results Layout

```
📁 /Users/YourName/Music/Artist/Album/
├── 🎵 Song Title.mp3 [320kbps, 8.2MB] ⭐ (Keep)
├── 🎵 Song Title.mp3 [128kbps, 3.3MB] ❌ (Remove)
└── 🎵 Song Title.flac [Lossless, 25.1MB] ⭐⭐ (Best)
```

### Status Indicators

- **⭐**: Recommended to keep (highest quality)
- **⭐⭐**: Best quality in group
- **❌**: Recommended for removal
- **🎵**: Audio file icon
- **📁**: Directory icon

### Statistics Summary

At the bottom of results, you'll see:

- **Total Files Scanned**: How many files were processed
- **Duplicate Groups Found**: Number of duplicate sets
- **Potential Space Savings**: How much space you could reclaim
- **Processing Time**: How long the scan took

## 🚀 Pro Tips

### For Better Results

1. **Organize First**: Clean up messy folder structures before scanning
2. **Large Batches**: Scan entire music library at once for best results
3. **Regular Scans**: Run scans periodically to catch new duplicates
4. **Preview Always**: Listen to files before deleting, especially for similar but not identical files

### Performance Tips

1. **SSD Storage**: Scans are much faster on solid-state drives
2. **Close Other Apps**: Free up CPU and memory for faster processing
3. **Exclude System Folders**: Don't scan system directories
4. **Reasonable Batch Sizes**: Scan 5,000-10,000 files at a time for very large libraries

### Organization Tips

1. **Consistent Naming**: Use consistent file naming conventions
2. **Folder Structure**: Organize by Artist/Album/Track
3. **Quality Standards**: Decide on quality standards for your library
4. **Regular Cleanup**: Scan and clean duplicates regularly

## 🔧 Common Issues

### "App won't open" (macOS)

1. **Right-click** AudioDUPER in Applications
2. **Select** "Open" from the context menu
3. **Click** "Open" in the security dialog
4. **This only needs to be done once**

### "Scan is very slow"

1. **Check storage type**: HDD is much slower than SSD
2. **Close other applications**: Free up system resources
3. **Scan smaller batches**: Process fewer files at once
4. **Exclude unnecessary files**: Filter out non-audio files

### "No duplicates found"

1. **Check directory**: Make sure you're scanning the right folder
2. **Look for similar files**: Some duplicates may have slight differences
3. **Try different formats**: Check if you have same songs in different formats
4. **Large library**: You might not have duplicates (that's good!)

### "Accidentally deleted wrong file"

1. **Don't panic**: Files are in trash/recycle bin
2. **Open system trash**: Restore the file immediately
3. **Check backup**: If you enabled backup options
4. **Rescan**: Run another scan to verify

## 📈 Next Steps

### After Your First Scan

1. **Review Other Folders**: Scan different music directories
2. **Configure Settings**: Customize quality preferences
3. **Set Up Regular Scans**: Make it part of your routine
4. **Explore Advanced Features**: Try export, filtering, and other options

### Learning More

- **[FAQ](FAQ.md)**: Answers to common questions
- **[Troubleshooting](TROUBLESHOOTING.md)**: Detailed problem-solving guide
- **[Community](https://github.com/sanchez314c/audio-duper/discussions)**: Get help from other users

## 🎉 Success!

You've successfully:
✅ Installed AudioDUPER  
✅ Scanned your music library  
✅ Identified duplicate audio files  
✅ Made informed decisions about file quality  
✅ Reclaimed storage space

**Congratulations!** You're now on your way to a cleaner, more organized music library.

## 📞 Need Help?

- **📖 Documentation**: Check the [FAQ](FAQ.md) for detailed features
- **❓ FAQ**: Browse the [FAQ](FAQ.md) for common questions
- **🐛 Issues**: Report bugs on [GitHub Issues](https://github.com/sanchez314c/audio-duper/issues)
- **💬 Community**: Join the [GitHub Discussions](https://github.com/sanchez314c/audio-duper/discussions)

---

**Happy duplicate hunting! 🎵🔍**

_Last updated: October 31, 2025_
