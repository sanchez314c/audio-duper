#!/bin/bash

# Build, Compile, and Distribute Script for Electron Apps
# Adapted from build-compile-dist-electron.md

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    print_error "No package.json found. Please run this script from the project root."
    exit 1
fi

# Backup existing dist folder if it exists
if [ -d "dist" ]; then
    print_status "Backing up existing dist folder..."
    mv dist dist.backup.$(date +%Y%m%d_%H%M%S)
fi

# Install dependencies
print_status "Installing dependencies..."
npm install

# Install electron-builder if not present
if ! npm list -g | grep -q electron-builder; then
    print_status "Installing electron-builder..."
    npm install -g electron-builder
fi

print_success "Dependencies ready"

# Build the application
print_status "Building application..."
npm run build 2>/dev/null || electron-builder --publish=never

print_success "Build completed successfully!"
print_status "Output files are in the 'dist' folder"

# List the generated files
if [ -d "dist" ]; then
    print_status "Generated files:"
    ls -la dist/
fi