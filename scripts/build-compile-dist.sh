#!/bin/bash

# Enhanced Build, Compile & Distribution Script for AudioDUPER
# Builds ALL platform variants with maximum optimization and bloat analysis

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Get the script directory and project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

# Parse command line arguments
TEMP_CLEAN=true
BLOAT_CHECK=true
PARALLEL=false
SKIP_TESTS=false

for arg in "$@"; do
    case $arg in
        --no-temp-clean)
            TEMP_CLEAN=false
            ;;
        --no-bloat-check)
            BLOAT_CHECK=false
            ;;
        --parallel)
            PARALLEL=true
            ;;
        --skip-tests)
            SKIP_TESTS=true
            ;;
        --help)
            echo "Usage: $0 [options]"
            echo "Options:"
            echo "  --no-temp-clean    Skip temporary file cleanup"
            echo "  --no-bloat-check   Skip bloat analysis"
            echo "  --parallel         Run builds in parallel where possible"
            echo "  --skip-tests       Skip test execution"
            echo "  --help             Show this help message"
            exit 0
            ;;
    esac
done

# Function to print colored output
print_status() {
    echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')] ✔${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[$(date +'%H:%M:%S')] ⚠${NC} $1"
}

print_error() {
    echo -e "${RED}[$(date +'%H:%M:%S')] ✗${NC} $1"
}

print_info() {
    echo -e "${CYAN}[$(date +'%H:%M:%S')] ℹ${NC} $1"
}

print_header() {
    echo ""
    echo -e "${PURPLE}════════════════════════════════════════════════════════${NC}"
    echo -e "${PURPLE} $1${NC}"
    echo -e "${PURPLE}════════════════════════════════════════════════════════${NC}"
    echo ""
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to display system information
show_system_info() {
    print_header "🖥️  System Information"

    echo "OS: $(uname -s)"
    echo "Architecture: $(uname -m)"
    echo "Node.js: $(node --version 2>/dev/null || echo 'Not installed')"
    echo "npm: $(npm --version 2>/dev/null || echo 'Not installed')"
    echo "Electron: $(npx electron --version 2>/dev/null || echo 'Not installed')"

    if command_exists electron-builder; then
        echo "electron-builder: $(electron-builder --version)"
    else
        echo "electron-builder: Not installed"
    fi

    # Available disk space
    if command_exists df; then
        echo "Available disk space: $(df -h . | tail -1 | awk '{print $4}')"
    fi
}

# Function to setup build environment
setup_build_env() {
    print_status "🔧 Setting up build environment..."

    # Set custom temp directory
    BUILD_TEMP_DIR="$PROJECT_ROOT/build-temp"
    mkdir -p "$BUILD_TEMP_DIR"
    export TMPDIR="$BUILD_TEMP_DIR"
    export TMP="$BUILD_TEMP_DIR"
    export TEMP="$BUILD_TEMP_DIR"
    export ELECTRON_CACHE="$BUILD_TEMP_DIR/electron-cache"

    # Ensure node_modules exists
    if [ ! -d "node_modules" ]; then
        print_warning "node_modules not found, installing dependencies..."
        npm ci
    fi

    # Clean previous builds
    if [ -d "dist" ]; then
        print_status "Cleaning previous build artifacts..."
        rm -rf dist/*
    fi

    print_success "Build environment ready"
}

# Function to run tests
run_tests() {
    if [ "$SKIP_TESTS" = true ]; then
        print_warning "Skipping tests as requested"
        return 0
    fi

    print_status "🧪 Running tests..."

    if npm run test 2>/dev/null; then
        print_success "All tests passed"
    else
        print_warning "Tests failed or not configured, continuing build..."
    fi

    # Run linting if available
    if npm run lint 2>/dev/null; then
        print_success "Linting passed"
    else
        print_warning "Linting failed or not configured"
    fi
}

# Function to build for current platform
build_current_platform() {
    local platform=$(uname -s)
    print_status "🏗️  Building for current platform: $platform"

    case $platform in
        Darwin)
            npm run build:mac
            ;;
        Linux*)
            npm run build:linux
            ;;
        CYGWIN*|MINGW*|MSYS*)
            npm run build:win
            ;;
        *)
            print_error "Unsupported platform: $platform"
            return 1
            ;;
    esac

    print_success "Current platform build completed"
}

# Function to build all platforms
build_all_platforms() {
    print_status "🌍 Building for all platforms..."

    # Build for macOS
    print_status "Building for macOS..."
    npm run build:mac

    # Build for Windows
    print_status "Building for Windows..."
    npm run build:win

    # Build for Linux
    print_status "Building for Linux..."
    npm run build:linux

    print_success "All platform builds completed"
}

# Function to perform comprehensive build (maximum)
build_maximum() {
    print_status "🚀 Running comprehensive build (maximum variants)..."

    npm run dist:maximum

    print_success "Comprehensive build completed"
}

# Function to run bloat analysis
run_bloat_analysis() {
    if [ "$BLOAT_CHECK" = false ]; then
        print_warning "Skipping bloat analysis as requested"
        return 0
    fi

    print_status "📊 Running bloat analysis..."

    if [ -f "$SCRIPT_DIR/bloat-check.sh" ]; then
        "$SCRIPT_DIR/bloat-check.sh"
    else
        print_warning "Bloat check script not found, performing basic analysis..."

        # Basic node_modules analysis
        if [ -d "node_modules" ]; then
            NODE_MODULES_SIZE=$(du -sh node_modules 2>/dev/null | cut -f1)
            print_info "node_modules size: $NODE_MODULES_SIZE"

            # Show largest packages
            print_info "Largest packages:"
            du -sh node_modules/* 2>/dev/null | sort -hr | head -5
        fi

        # Basic dist analysis
        if [ -d "dist" ]; then
            DIST_SIZE=$(du -sh dist 2>/dev/null | cut -f1)
            print_info "Distribution size: $DIST_SIZE"
        fi
    fi
}

# Function to cleanup temporary files
cleanup_temp() {
    if [ "$TEMP_CLEAN" = false ]; then
        print_warning "Skipping temporary file cleanup as requested"
        return 0
    fi

    print_status "🧹 Cleaning up temporary files..."

    # Remove build temp directory
    if [ -d "$BUILD_TEMP_DIR" ]; then
        rm -rf "$BUILD_TEMP_DIR"
        print_success "Removed build temp directory"
    fi

    # Clean node_modules cache
    if [ -d "node_modules/.cache" ]; then
        rm -rf node_modules/.cache
        print_success "Cleaned node_modules cache"
    fi

    # Run temp-cleanup script if available
    if [ -f "$SCRIPT_DIR/temp-cleanup.sh" ]; then
        "$SCRIPT_DIR/temp-cleanup.sh"
    fi
}

# Function to show build summary
show_build_summary() {
    print_header "📋 Build Summary"

    echo "Build completed at: $(date)"
    echo "Project: $PROJECT_ROOT"

    if [ -d "dist" ]; then
        echo ""
        print_info "Generated artifacts:"
        find dist -type f \( -name "*.dmg" -o -name "*.exe" -o -name "*.deb" -o -name "*.rpm" -o -name "*.AppImage" -o -name "*.zip" \) | while read file; do
            SIZE=$(du -sh "$file" 2>/dev/null | cut -f1)
            echo "  $file ($SIZE)"
        done

        TOTAL_SIZE=$(du -sh dist 2>/dev/null | cut -f1)
        echo ""
        print_info "Total distribution size: $TOTAL_SIZE"
    else
        print_warning "No distribution artifacts found"
    fi
}

# Main execution
main() {
    print_header "🎵 AudioDUPER Build System"
    print_info "Starting build process..."

    # Show system information
    show_system_info

    # Setup build environment
    setup_build_env

    # Run tests
    run_tests

    # Determine build type
    if [ "$1" = "all" ] || [ "$1" = "maximum" ]; then
        if [ "$1" = "maximum" ]; then
            build_maximum
        else
            build_all_platforms
        fi
    else
        build_current_platform
    fi

    # Run bloat analysis
    run_bloat_analysis

    # Show build summary
    show_build_summary

    # Cleanup temporary files
    cleanup_temp

    print_header "✅ Build Complete"
    print_success "AudioDUPER build process completed successfully!"

    if [ -d "dist" ]; then
        print_info "Check the 'dist' directory for generated installers"
    fi
}

# Handle Ctrl+C gracefully
trap 'print_error "Build interrupted by user"; exit 1' INT

# Run main function with all arguments
main "$@"