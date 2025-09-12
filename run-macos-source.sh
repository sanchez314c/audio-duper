#!/bin/bash

# Run AudioDUPER from source on macOS
# For development and testing purposes

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

print_status "🎵 Starting AudioDUPER from source on macOS..."

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    print_error "No package.json found. Please run this script from the AudioDUPER root directory."
    exit 1
fi

# Check for Node.js
if ! command -v node &> /dev/null; then
    print_error "Node.js is not installed. Please install Node.js first."
    print_status "Install via: brew install node"
    exit 1
fi

# Check for npm
if ! command -v npm &> /dev/null; then
    print_error "npm is not installed. Please install npm first."
    exit 1
fi

# Install dependencies if node_modules doesn't exist
if [ ! -d "node_modules" ]; then
    print_status "Installing dependencies..."
    npm install
    if [ $? -ne 0 ]; then
        print_error "Failed to install dependencies"
        exit 1
    fi
fi

# Check for system dependencies
print_status "Checking system dependencies..."

# Check for chromaprint (required for audio fingerprinting)
if ! command -v fpcalc &> /dev/null; then
    print_warning "chromaprint (fpcalc) not found. Installing via Homebrew..."
    if command -v brew &> /dev/null; then
        brew install chromaprint
    else
        print_error "Homebrew not found. Please install chromaprint manually:"
        print_status "brew install chromaprint"
        exit 1
    fi
fi

print_success "All dependencies verified"

# Start the application in development mode
print_status "🚀 Launching AudioDUPER in development mode..."
print_status "Press Ctrl+C to stop the application"
print_status ""

# Run with development environment
NODE_ENV=development npm run dev

print_success "AudioDUPER closed successfully"