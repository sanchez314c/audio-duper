#!/bin/bash

# Run AudioDUPER from built application on macOS
# Locates and launches the built .app bundle

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

print_status "🎵 Starting AudioDUPER from built application on macOS..."

# Look for built application in common locations
APP_PATHS=(
    "dist/mac/AudioDUPER.app"
    "dist/mac-arm64/AudioDUPER.app"
    "dist/AudioDUPER.app"
)

APP_FOUND=""
for app_path in "${APP_PATHS[@]}"; do
    if [ -d "$app_path" ]; then
        APP_FOUND="$app_path"
        print_success "Found AudioDUPER.app at: $app_path"
        break
    fi
done

if [ -z "$APP_FOUND" ]; then
    print_error "AudioDUPER.app not found. Please build the application first:"
    print_status "Run: npm run build"
    print_status "Or: ./compile-build-dist-comprehensive.sh --platform mac"
    exit 1
fi

# Check if the app bundle is valid
if [ ! -f "$APP_FOUND/Contents/MacOS/AudioDUPER" ]; then
    print_error "Invalid app bundle. Missing executable at $APP_FOUND/Contents/MacOS/AudioDUPER"
    print_status "Please rebuild the application"
    exit 1
fi

# Launch the application
print_status "🚀 Launching AudioDUPER..."
open "$APP_FOUND"

print_success "AudioDUPER launched successfully"
print_status "Application running independently. You can close this terminal."