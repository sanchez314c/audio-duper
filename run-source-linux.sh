#!/bin/bash
set -e

# Run AudioDUPER from Source on Linux
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')] ✔${NC} $1"
}

print_error() {
    echo -e "${RED}[$(date +'%H:%M:%S')] ✗${NC} $1"
}

# Check if we're on Linux
if [ "$(uname)" != "Linux" ]; then
    print_error "This script is for Linux only"
    exit 1
fi

print_status "Starting AudioDUPER from source (Linux)..."

# Check dependencies
if ! command -v npm &>/dev/null; then
    print_error "npm is not installed. Install with: sudo apt install npm"
    exit 1
fi

if ! command -v node &>/dev/null; then
    print_error "node is not installed. Install with: sudo apt install nodejs"
    exit 1
fi

# Fix Electron sandbox permission issue on Linux
sudo sysctl -w kernel.unprivileged_userns_clone=1 &>/dev/null 2>&1 || true

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
    print_status "Installing dependencies..."
    npm install
fi

# Set Electron flags for Linux
export ELECTRON_FORCE_WINDOW_MENU_BAR=1
export ELECTRON_TRASH=gio
export ELECTRON_DISABLE_SANDBOX=1

# Use all CPU cores for builds
export UV_THREADPOOL_SIZE=$(nproc)

# Run the app
print_status "Launching Electron application..."
if grep -q '"dev"' package.json; then
    npm run dev
elif grep -q '"start"' package.json; then
    npm start
else
    print_error "No suitable run command found in package.json"
    exit 1
fi

print_success "Application session ended"
