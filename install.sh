#!/bin/bash

# AudioDUPER Installation Script
# Automatically installs dependencies and sets up the application

set -e  # Exit on any error

echo "🎵 AudioDUPER Installation Script"
echo "================================="
echo ""

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

# Check if running on supported OS
check_os() {
    print_status "Checking operating system..."
    
    case "$OSTYPE" in
        darwin*)
            OS="macOS"
            PACKAGE_MANAGER="brew"
            ;;
        linux*)
            OS="Linux"
            if command -v apt-get > /dev/null; then
                PACKAGE_MANAGER="apt"
            elif command -v yum > /dev/null; then
                PACKAGE_MANAGER="yum"
            elif command -v pacman > /dev/null; then
                PACKAGE_MANAGER="pacman"
            else
                print_error "Unsupported Linux distribution"
                exit 1
            fi
            ;;
        msys*|win32*|cygwin*)
            OS="Windows"
            print_error "Please use install.bat on Windows"
            exit 1
            ;;
        *)
            print_error "Unsupported operating system: $OSTYPE"
            exit 1
            ;;
    esac
    
    print_success "Detected $OS"
}

# Check if Node.js is installed and version is sufficient
check_nodejs() {
    print_status "Checking Node.js installation..."
    
    if ! command -v node > /dev/null; then
        print_error "Node.js is not installed"
        print_status "Please install Node.js 16+ from https://nodejs.org/"
        exit 1
    fi
    
    NODE_VERSION=$(node -v | cut -c 2-)
    MAJOR_VERSION=$(echo $NODE_VERSION | cut -d. -f1)
    
    if [ "$MAJOR_VERSION" -lt 16 ]; then
        print_error "Node.js version $NODE_VERSION is too old"
        print_status "Please upgrade to Node.js 16 or higher"
        exit 1
    fi
    
    print_success "Node.js $NODE_VERSION detected"
}

# Check if npm is available
check_npm() {
    print_status "Checking npm installation..."
    
    if ! command -v npm > /dev/null; then
        print_error "npm is not installed"
        print_status "Please install npm (usually comes with Node.js)"
        exit 1
    fi
    
    NPM_VERSION=$(npm -v)
    print_success "npm $NPM_VERSION detected"
}

# Install system dependencies
install_system_deps() {
    print_status "Installing system dependencies..."
    
    case "$OS" in
        "macOS")
            if ! command -v brew > /dev/null; then
                print_warning "Homebrew not found, attempting to install..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi
            
            if ! brew list chromaprint > /dev/null 2>&1; then
                print_status "Installing chromaprint via Homebrew..."
                brew install chromaprint
            else
                print_success "chromaprint already installed"
            fi
            ;;
            
        "Linux")
            case "$PACKAGE_MANAGER" in
                "apt")
                    print_status "Installing chromaprint via apt..."
                    sudo apt-get update
                    sudo apt-get install -y libchromaprint-tools libchromaprint-dev
                    ;;
                "yum")
                    print_status "Installing chromaprint via yum..."
                    sudo yum install -y chromaprint-tools chromaprint-devel
                    ;;
                "pacman")
                    print_status "Installing chromaprint via pacman..."
                    sudo pacman -S --noconfirm chromaprint
                    ;;
            esac
            ;;
    esac
    
    print_success "System dependencies installed"
}

# Install Node.js dependencies
install_node_deps() {
    print_status "Installing Node.js dependencies..."
    
    if [ ! -f "package.json" ]; then
        print_error "package.json not found. Are you in the AudioDUPER directory?"
        exit 1
    fi
    
    # Clear npm cache to avoid potential issues
    npm cache clean --force > /dev/null 2>&1 || true
    
    # Install dependencies
    npm install --no-audit --no-fund
    
    print_success "Node.js dependencies installed"
}

# Verify installation
verify_installation() {
    print_status "Verifying installation..."
    
    # Check if all required node modules are present
    if [ ! -d "node_modules" ]; then
        print_error "node_modules directory not found"
        exit 1
    fi
    
    # Check for main dependencies
    REQUIRED_MODULES=("electron" "fpcalc" "music-metadata")
    for module in "${REQUIRED_MODULES[@]}"; do
        if [ ! -d "node_modules/$module" ]; then
            print_error "Required module $module not found"
            exit 1
        fi
    done
    
    print_success "Installation verified successfully"
}

# Create desktop shortcut (Linux/macOS)
create_shortcut() {
    print_status "Creating application shortcut..."
    
    CURRENT_DIR=$(pwd)
    APP_NAME="AudioDUPER"
    
    case "$OS" in
        "Linux")
            DESKTOP_FILE="$HOME/Desktop/$APP_NAME.desktop"
            cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=AudioDUPER
Comment=Intelligent Audio Duplicate Detection
Exec=sh -c "cd '$CURRENT_DIR' && npm start"
Icon=$CURRENT_DIR/assets/icon.png
Terminal=false
Categories=AudioVideo;Audio;
EOF
            chmod +x "$DESKTOP_FILE"
            print_success "Desktop shortcut created: $DESKTOP_FILE"
            ;;
            
        "macOS")
            # Create an alias that can be moved to Applications
            print_status "To add to Applications folder:"
            print_status "  1. Open Finder"
            print_status "  2. Navigate to this directory: $CURRENT_DIR"
            print_status "  3. Run: npm start"
            ;;
    esac
}

# Main installation process
main() {
    echo "Starting AudioDUPER installation..."
    echo ""
    
    check_os
    check_nodejs
    check_npm
    
    print_status "Installing system dependencies..."
    install_system_deps
    
    print_status "Installing application dependencies..."
    install_node_deps
    
    verify_installation
    create_shortcut
    
    echo ""
    print_success "✅ AudioDUPER installation completed successfully!"
    echo ""
    print_status "To start the application, run:"
    echo "  npm start"
    echo ""
    print_status "For development mode with debugging:"
    echo "  npm run dev"
    echo ""
    print_status "To build for distribution:"
    echo "  npm run build"
    echo ""
    print_status "Enjoy organizing your music collection! 🎵"
}

# Run main function
main "$@"