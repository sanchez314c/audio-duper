#!/bin/bash

# Standalone Temp Cleanup Tool for AudioDUPER
# Cleans system temp directories, build artifacts, and development caches

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

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

# Command line flags
DRY_RUN=false
AGGRESSIVE=false
SYSTEM_ONLY=false
PROJECT_ONLY=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --aggressive)
            AGGRESSIVE=true
            shift
            ;;
        --system-only)
            SYSTEM_ONLY=true
            shift
            ;;
        --project-only)
            PROJECT_ONLY=true
            shift
            ;;
        --help)
            echo "AudioDUPER Temp Cleanup Tool"
            echo ""
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --dry-run      Show what would be cleaned without actually cleaning"
            echo "  --aggressive   More thorough cleanup (includes older files)"
            echo "  --system-only  Clean only system temp directories"
            echo "  --project-only Clean only project-specific files"
            echo "  --help         Show this help message"
            echo ""
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

print_header "🧹 AUDIODUPER TEMP CLEANUP TOOL"

if [ "$DRY_RUN" = true ]; then
    print_warning "DRY RUN MODE - No files will actually be deleted"
fi

if [ "$AGGRESSIVE" = true ]; then
    print_info "AGGRESSIVE MODE - More thorough cleanup enabled"
fi

# Function to safely remove files/directories
safe_remove() {
    local target="$1"
    local description="$2"
    
    if [ "$DRY_RUN" = true ]; then
        if [ -e "$target" ]; then
            print_info "[DRY RUN] Would remove: $target ($description)"
        fi
        return 0
    fi
    
    if [ -e "$target" ]; then
        local size="0"
        if [ -f "$target" ]; then
            size=$(ls -lah "$target" | awk '{print $5}')
        elif [ -d "$target" ]; then
            size=$(du -sh "$target" 2>/dev/null | cut -f1 || echo "unknown")
        fi
        
        rm -rf "$target" 2>/dev/null || true
        print_success "Removed: $description ($size)"
    fi
}

# Function to clean system temp directories
clean_system_temp() {
    print_status "🧹 Cleaning system temp directories..."
    
    case "$(uname)" in
        Darwin)
            # macOS temp cleanup
            if [ -d "/private/var/folders" ]; then
                TEMP_DIRS=$(find /private/var/folders -name "Temporary*" -type d 2>/dev/null | head -5)
                
                for TEMP_DIR in $TEMP_DIRS; do
                    if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
                        PARENT_DIR=$(dirname "$TEMP_DIR")
                        
                        # Show before size
                        if [ "$DRY_RUN" = false ]; then
                            BEFORE_SIZE=$(du -sh "$PARENT_DIR" 2>/dev/null | cut -f1 || echo "unknown")
                            print_info "Cleaning temp directory: $PARENT_DIR (size: $BEFORE_SIZE)"
                        fi
                        
                        # Clean build artifacts (older than 1 day or all if aggressive)
                        if [ "$AGGRESSIVE" = true ]; then
                            find "$PARENT_DIR" -name "t-*" -type d -exec rm -rf {} + 2>/dev/null || true
                            find "$PARENT_DIR" -name "electron-download-*" -type d -exec rm -rf {} + 2>/dev/null || true
                        else
                            find "$PARENT_DIR" -name "t-*" -type d -mtime +1 -exec rm -rf {} + 2>/dev/null || true
                            find "$PARENT_DIR" -name "electron-download-*" -type d -mtime +1 -exec rm -rf {} + 2>/dev/null || true
                        fi
                        
                        # Clean specific temp files
                        find "$PARENT_DIR" -name "CFNetworkDownload_*.tmp" -mtime +1 -delete 2>/dev/null || true
                        find "$PARENT_DIR" -name "package-dir-staging-*" -type d -mtime +1 -exec rm -rf {} + 2>/dev/null || true
                        find "$PARENT_DIR" -name "com.anthropic.claudefordesktop.ShipIt.*" -type d -mtime +1 -exec rm -rf {} + 2>/dev/null || true
                        
                        # Show after size
                        if [ "$DRY_RUN" = false ]; then
                            AFTER_SIZE=$(du -sh "$PARENT_DIR" 2>/dev/null | cut -f1 || echo "unknown")
                            print_success "System temp cleanup: $BEFORE_SIZE → $AFTER_SIZE"
                        fi
                    fi
                done
                
                # Clean Electron-specific caches
                safe_remove "$HOME/Library/Caches/Electron" "Electron cache"
                safe_remove "$HOME/.electron" "Electron user cache"
                
                if [ "$AGGRESSIVE" = true ]; then
                    safe_remove "$HOME/Library/Caches/npm" "npm cache"
                    safe_remove "$HOME/.npm/_cacache" "npm cacache"
                fi
            fi
            ;;
            
        Linux)
            # Linux temp cleanup
            if [ -d "/tmp" ]; then
                BEFORE_SIZE=$(du -sh /tmp 2>/dev/null | cut -f1 || echo "unknown")
                print_info "Cleaning /tmp directory (size: $BEFORE_SIZE)"
                
                if [ "$AGGRESSIVE" = true ]; then
                    find /tmp -name "electron-*" -type d -exec rm -rf {} + 2>/dev/null || true
                    find /tmp -name "npm-*" -type d -exec rm -rf {} + 2>/dev/null || true
                    find /tmp -name "node-*" -type d -exec rm -rf {} + 2>/dev/null || true
                else
                    find /tmp -name "electron-*" -type d -mtime +1 -exec rm -rf {} + 2>/dev/null || true
                    find /tmp -name "npm-*" -type d -mtime +1 -exec rm -rf {} + 2>/dev/null || true
                    find /tmp -name "node-*" -type d -mtime +1 -exec rm -rf {} + 2>/dev/null || true
                fi
                
                AFTER_SIZE=$(du -sh /tmp 2>/dev/null | cut -f1 || echo "unknown")
                print_success "System temp cleanup: $BEFORE_SIZE → $AFTER_SIZE"
            fi
            
            # Clean user-specific caches
            safe_remove "$HOME/.cache/electron" "Electron user cache"
            safe_remove "$HOME/.config/Electron" "Electron config cache"
            
            if [ "$AGGRESSIVE" = true ]; then
                safe_remove "$HOME/.npm/_cacache" "npm cache"
                safe_remove "$HOME/.cache/npm" "npm cache (alternate location)"
            fi
            ;;
            
        CYGWIN*|MINGW*|MSYS*)
            # Windows/Git Bash cleanup
            if [ -d "/tmp" ]; then
                find /tmp -name "electron-*" -type d -mtime +1 -exec rm -rf {} + 2>/dev/null || true
                find /tmp -name "npm-*" -type d -mtime +1 -exec rm -rf {} + 2>/dev/null || true
            fi
            
            # Windows-specific paths
            if [ -d "$APPDATA/npm-cache" ]; then
                safe_remove "$APPDATA/npm-cache" "npm cache"
            fi
            
            if [ -d "$LOCALAPPDATA/electron" ]; then
                safe_remove "$LOCALAPPDATA/electron" "Electron cache"
            fi
            ;;
    esac
}

# Function to clean project-specific files
clean_project_files() {
    print_status "🏗️ Cleaning project-specific temp files..."
    
    # Get current directory
    PROJECT_DIR="$(pwd)"
    
    # Clean build directories
    safe_remove "$PROJECT_DIR/dist" "Build output directory"
    safe_remove "$PROJECT_DIR/build" "Build directory"
    safe_remove "$PROJECT_DIR/out" "Output directory"
    safe_remove "$PROJECT_DIR/release" "Release directory"
    
    # Clean cache directories
    safe_remove "$PROJECT_DIR/node_modules/.cache" "Node modules cache"
    safe_remove "$PROJECT_DIR/.cache" "Project cache"
    
    # Clean log files
    find "$PROJECT_DIR" -name "*.log" -mtime +7 -delete 2>/dev/null || true
    find "$PROJECT_DIR" -name "npm-debug.log*" -delete 2>/dev/null || true
    find "$PROJECT_DIR" -name "yarn-debug.log*" -delete 2>/dev/null || true
    find "$PROJECT_DIR" -name "yarn-error.log*" -delete 2>/dev/null || true
    
    # Clean OS-specific files
    case "$(uname)" in
        Darwin)
            find "$PROJECT_DIR" -name ".DS_Store" -delete 2>/dev/null || true
            find "$PROJECT_DIR" -name "._*" -delete 2>/dev/null || true
            ;;
        CYGWIN*|MINGW*|MSYS*)
            find "$PROJECT_DIR" -name "Thumbs.db" -delete 2>/dev/null || true
            find "$PROJECT_DIR" -name "desktop.ini" -delete 2>/dev/null || true
            ;;
    esac
    
    # Clean editor temp files
    find "$PROJECT_DIR" -name "*~" -delete 2>/dev/null || true
    find "$PROJECT_DIR" -name ".#*" -delete 2>/dev/null || true
    find "$PROJECT_DIR" -name "#*#" -delete 2>/dev/null || true
    
    # Clean electron-builder temp files
    safe_remove "$PROJECT_DIR/build/electron" "Electron builder temp"
    
    if [ "$AGGRESSIVE" = true ]; then
        print_warning "Aggressive mode: Cleaning node_modules (will require npm install)"
        safe_remove "$PROJECT_DIR/node_modules" "Node modules directory"
        safe_remove "$PROJECT_DIR/package-lock.json" "Package lock file"
        safe_remove "$PROJECT_DIR/yarn.lock" "Yarn lock file"
    fi
}

# Function to show cleanup summary
show_cleanup_summary() {
    print_header "📊 CLEANUP SUMMARY"
    
    # Calculate free space gained (approximation)
    if command -v df >/dev/null 2>&1; then
        case "$(uname)" in
            Darwin)
                AVAILABLE_SPACE=$(df -h . | tail -1 | awk '{print $4}')
                print_info "Available disk space: $AVAILABLE_SPACE"
                ;;
            Linux)
                AVAILABLE_SPACE=$(df -h . | tail -1 | awk '{print $4}')
                print_info "Available disk space: $AVAILABLE_SPACE"
                ;;
        esac
    fi
    
    print_info ""
    print_info "🧹 Cleanup recommendations:"
    print_info "  • Run this script monthly for optimal performance"
    print_info "  • Use --aggressive flag for deep cleaning when needed"
    print_info "  • Consider automating cleanup with cron/scheduled tasks"
    print_info "  • Monitor disk usage regularly"
    
    if [ "$DRY_RUN" = true ]; then
        print_warning "This was a dry run. Use without --dry-run to perform actual cleanup."
    fi
}

# Main execution
main() {
    # Determine what to clean based on flags
    if [ "$SYSTEM_ONLY" = true ]; then
        clean_system_temp
    elif [ "$PROJECT_ONLY" = true ]; then
        clean_project_files
    else
        # Clean both by default
        clean_system_temp
        echo ""
        clean_project_files
    fi
    
    echo ""
    show_cleanup_summary
    
    print_header "✅ CLEANUP COMPLETE"
    
    if [ "$DRY_RUN" = false ]; then
        print_success "Temp cleanup completed successfully!"
        print_info "System and project files have been cleaned"
    else
        print_info "Dry run completed. Review the output above."
    fi
}

# Run main function
main "$@"