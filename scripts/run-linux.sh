#!/bin/bash

# Run AudioDUPER from built application on Linux
# Locates and launches the built executable or AppImage

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Get the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

print_status "🎵 Starting AudioDUPER from built application on Linux..."

# Look for built application in common locations
APP_PATHS=(
    "dist/linux-unpacked/AudioDUPER"
    "dist/AudioDUPER"
)

# Look for AppImage files
APPIMAGE_PATHS=(
    "dist/*.AppImage"
    "AudioDUPER*.AppImage"
)

APP_FOUND=""
APP_TYPE=""

# Check for regular executable
for app_path in "${APP_PATHS[@]}"; do
    if [ -f "$app_path" ] && [ -x "$app_path" ]; then
        APP_FOUND="$app_path"
        APP_TYPE="executable"
        print_success "Found AudioDUPER executable at: $app_path"
        break
    fi
done

# If no executable found, check for AppImage
if [ -z "$APP_FOUND" ]; then
    for appimage_pattern in "${APPIMAGE_PATHS[@]}"; do
        for appimage_file in $appimage_pattern; do
            if [ -f "$appimage_file" ] && [ -x "$appimage_file" ]; then
                APP_FOUND="$appimage_file"
                APP_TYPE="appimage"
                print_success "Found AudioDUPER AppImage at: $appimage_file"
                break 2
            fi
        done
    done
fi

if [ -z "$APP_FOUND" ]; then
    print_error "AudioDUPER executable or AppImage not found. Please build the application first:"
    print_status "Run: npm run build"
    print_status "Or: ./compile-build-dist-comprehensive.sh --platform linux"
    exit 1
fi

# Check X11 display
if [ -z "$DISPLAY" ]; then
    print_warning "No X11 display detected. GUI may not work properly."
    print_status "If running over SSH, try: ssh -X username@host"
    print_status "Or set DISPLAY variable: export DISPLAY=:0"
fi

# Additional checks for AppImage
if [ "$APP_TYPE" = "appimage" ]; then
    # Check for FUSE (required for AppImage on some systems)
    if ! command -v fusermount &> /dev/null && ! command -v fusermount3 &> /dev/null; then
        print_warning "FUSE not found. AppImage may not work on this system."
        print_status "Install FUSE:"
        print_status "  Ubuntu/Debian: sudo apt install fuse"
        print_status "  CentOS/RHEL: sudo dnf install fuse"
    fi
    
    # Make sure AppImage is executable
    chmod +x "$APP_FOUND"
fi

# Launch the application
print_status "🚀 Launching AudioDUPER ($APP_TYPE)..."

if [ "$APP_TYPE" = "appimage" ]; then
    # Launch AppImage
    "$APP_FOUND" &
else
    # Launch regular executable
    "$APP_FOUND" &
fi

APP_PID=$!

if [ $? -eq 0 ]; then
    print_success "AudioDUPER launched successfully (PID: $APP_PID)"
    print_status "Application running independently. You can close this terminal."
else
    print_error "Failed to launch AudioDUPER"
    exit 1
fi

# Optional: Wait a moment to see if the app starts successfully
sleep 2
if kill -0 $APP_PID 2>/dev/null; then
    print_success "Application is running successfully"
else
    print_error "Application may have crashed on startup"
    print_status "Check the application logs for more information"
fi