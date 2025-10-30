#!/bin/bash

# Standalone Bloat Analysis Tool for AudioDUPER
# Analyzes package size, dependencies, and identifies optimization opportunities

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

# Get the script directory and project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

print_header "🔍 AUDIODUPER BLOAT ANALYSIS TOOL"

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    print_error "No package.json found. Please run this script from the AudioDUPER root directory."
    exit 1
fi

# Function to convert bytes to human readable format
human_readable_size() {
    local bytes=$1
    if [ $bytes -ge 1073741824 ]; then
        echo "$(( bytes / 1073741824 ))GB"
    elif [ $bytes -ge 1048576 ]; then
        echo "$(( bytes / 1048576 ))MB"
    elif [ $bytes -ge 1024 ]; then
        echo "$(( bytes / 1024 ))KB"
    else
        echo "${bytes}B"
    fi
}

# Analyze node_modules
analyze_node_modules() {
    print_status "📦 Analyzing node_modules..."
    
    if [ ! -d "node_modules" ]; then
        print_warning "node_modules not found. Run 'npm install' first."
        return
    fi
    
    NODE_SIZE=$(du -sh node_modules/ 2>/dev/null | cut -f1)
    NODE_BYTES=$(du -sb node_modules/ 2>/dev/null | cut -f1)
    print_info "Total node_modules size: $NODE_SIZE"
    
    # Count packages
    PACKAGE_COUNT=$(find node_modules -name "package.json" -path "*/node_modules/*" | wc -l)
    print_info "Total packages installed: $PACKAGE_COUNT"
    
    # Find largest packages
    print_info "Top 10 largest packages:"
    du -sh node_modules/* 2>/dev/null | sort -hr | head -10 | while read size dir; do
        package_name=$(basename "$dir")
        print_info "  $size - $package_name"
    done
    
    # Analyze by category
    echo ""
    print_info "Package analysis by category:"
    
    # Count dev vs production dependencies
    if [ -f "package-lock.json" ]; then
        DEV_COUNT=$(jq '.dependencies | to_entries[] | select(.value.dev == true) | .key' package-lock.json 2>/dev/null | wc -l || echo "0")
        PROD_COUNT=$(jq '.dependencies | to_entries[] | select(.value.dev != true) | .key' package-lock.json 2>/dev/null | wc -l || echo "0")
        print_info "  Production dependencies: $PROD_COUNT"
        print_info "  Development dependencies: $DEV_COUNT"
    fi
    
    # Check for common bloat patterns
    check_bloat_patterns
}

# Check for common bloat patterns
check_bloat_patterns() {
    print_status "🚨 Checking for common bloat patterns..."
    
    # Check for multiple versions of the same package
    DUPLICATE_PACKAGES=$(npm ls --depth=0 2>/dev/null | grep -E "UNMET|extraneous" | wc -l)
    if [ $DUPLICATE_PACKAGES -gt 0 ]; then
        print_warning "Found $DUPLICATE_PACKAGES potential duplicate or problematic packages"
        print_info "Run 'npm dedupe' to resolve duplicates"
    fi
    
    # Check for large electron downloads
    if [ -d "node_modules/electron" ]; then
        ELECTRON_SIZE=$(du -sh node_modules/electron 2>/dev/null | cut -f1)
        print_info "Electron cache size: $ELECTRON_SIZE"
    fi
    
    # Check for unnecessary test/demo files in production
    TEST_FILES=$(find node_modules -name "test" -o -name "tests" -o -name "spec" -o -name "demo" -o -name "example" -o -name "examples" 2>/dev/null | wc -l)
    if [ $TEST_FILES -gt 10 ]; then
        print_warning "Found $TEST_FILES test/demo directories in node_modules (may indicate bloat)"
    fi
    
    # Check for source maps in production
    SOURCE_MAPS=$(find node_modules -name "*.map" 2>/dev/null | wc -l)
    if [ $SOURCE_MAPS -gt 50 ]; then
        print_warning "Found $SOURCE_MAPS source map files (consider removing for production)"
    fi
    
    # Check package.json for bloat indicators
    if grep -q '"node_modules/\*\*/\*"' package.json 2>/dev/null; then
        print_warning "⚠️  BLOAT WARNING: node_modules/**/* found in build files configuration"
    fi
}

# Analyze build output
analyze_build_output() {
    print_status "🏗️ Analyzing build output..."
    
    if [ ! -d "dist" ]; then
        print_warning "No dist directory found. Run build first to analyze output."
        return
    fi
    
    TOTAL_SIZE=$(du -sh dist/ 2>/dev/null | cut -f1)
    print_info "Total build output size: $TOTAL_SIZE"
    
    # Analyze individual packages
    echo ""
    print_info "Built packages:"
    for file in dist/*.dmg dist/*.exe dist/*.msi dist/*.AppImage dist/*.zip dist/*.deb dist/*.rpm; do
        if [ -f "$file" ]; then
            SIZE=$(ls -lah "$file" | awk '{print $5}')
            NAME=$(basename "$file")
            print_info "  $NAME: $SIZE"
            
            # Warning for large files
            SIZE_MB=$(ls -l "$file" | awk '{print int($5/1024/1024)}')
            if [ "$SIZE_MB" -gt 500 ]; then
                print_warning "    ⚠️  Large package detected: $NAME ($SIZE)"
            fi
            
            # Optimal size recommendations
            case "$NAME" in
                *.exe|*.msi)
                    if [ "$SIZE_MB" -gt 300 ]; then
                        print_info "    💡 Windows apps should typically be under 300MB"
                    fi
                    ;;
                *.dmg)
                    if [ "$SIZE_MB" -gt 400 ]; then
                        print_info "    💡 macOS apps should typically be under 400MB"
                    fi
                    ;;
                *.AppImage)
                    if [ "$SIZE_MB" -gt 350 ]; then
                        print_info "    💡 AppImages should typically be under 350MB"
                    fi
                    ;;
            esac
        fi
    done
}

# Dependency analysis
analyze_dependencies() {
    print_status "🔗 Analyzing dependencies..."
    
    if [ -f "package.json" ]; then
        # Count dependencies
        PROD_DEPS=$(jq '.dependencies // {} | length' package.json)
        DEV_DEPS=$(jq '.devDependencies // {} | length' package.json)
        
        print_info "Package.json dependencies:"
        print_info "  Production: $PROD_DEPS"
        print_info "  Development: $DEV_DEPS"
        
        # Check for heavy dependencies
        echo ""
        print_info "Checking for potentially heavy dependencies:"
        
        HEAVY_DEPS=("webpack" "babel" "typescript" "sass" "less" "postcss" "rollup" "parcel" "esbuild")
        for dep in "${HEAVY_DEPS[@]}"; do
            if jq -e ".dependencies[\"$dep\"] or .devDependencies[\"$dep\"]" package.json >/dev/null 2>&1; then
                print_info "  Found: $dep (build tool - check if needed in production)"
            fi
        done
        
        # Check for multiple similar packages
        UI_LIBS=$(jq -r '.dependencies // {}, .devDependencies // {} | keys[]' package.json | grep -E "(react|vue|angular|svelte)" | wc -l)
        if [ $UI_LIBS -gt 1 ]; then
            print_warning "Multiple UI frameworks detected - may cause bloat"
        fi
        
        CSS_LIBS=$(jq -r '.dependencies // {}, .devDependencies // {} | keys[]' package.json | grep -E "(sass|less|stylus|postcss)" | wc -l)
        if [ $CSS_LIBS -gt 2 ]; then
            print_warning "Multiple CSS preprocessors detected"
        fi
    fi
}

# Generate optimization recommendations
generate_recommendations() {
    print_header "💡 OPTIMIZATION RECOMMENDATIONS"
    
    print_info "🚀 Performance Optimizations:"
    print_info "  • Run 'npm dedupe' to remove duplicate packages"
    print_info "  • Use 'npm prune --production' to remove dev dependencies in production"
    print_info "  • Enable compression in electron-builder configuration"
    print_info "  • Consider using webpack bundle analyzer for detailed analysis"
    
    print_info ""
    print_info "📦 Package Optimizations:"
    print_info "  • Review package.json 'files' array to exclude unnecessary files"
    print_info "  • Remove unused dependencies with 'npm-check-unused' or 'depcheck'"
    print_info "  • Consider lighter alternatives for heavy dependencies"
    print_info "  • Use 'electron-builder-notarize' only when needed"
    
    print_info ""
    print_info "🏗️ Build Optimizations:"
    print_info "  • Enable tree-shaking in your bundler configuration"
    print_info "  • Minimize assets (images, fonts) before bundling"
    print_info "  • Use production builds for all dependencies"
    print_info "  • Consider code splitting for large applications"
    
    print_info ""
    print_info "📊 Monitoring:"
    print_info "  • Run this script regularly during development"
    print_info "  • Set up size budgets in your CI/CD pipeline"
    print_info "  • Monitor bundle size trends over time"
}

# Summary statistics
generate_summary() {
    print_header "📊 BLOAT ANALYSIS SUMMARY"
    
    TOTAL_SCORE=100
    
    # Calculate bloat score based on various factors
    if [ -d "node_modules" ]; then
        NODE_SIZE_MB=$(du -sm node_modules 2>/dev/null | cut -f1)
        if [ $NODE_SIZE_MB -gt 500 ]; then
            TOTAL_SCORE=$((TOTAL_SCORE - 20))
            print_warning "Large node_modules detected (${NODE_SIZE_MB}MB) - Score: -20"
        elif [ $NODE_SIZE_MB -gt 250 ]; then
            TOTAL_SCORE=$((TOTAL_SCORE - 10))
            print_warning "Moderate node_modules size (${NODE_SIZE_MB}MB) - Score: -10"
        fi
    fi
    
    if [ -d "dist" ]; then
        # Count large packages
        LARGE_PACKAGES=$(find dist -name "*.dmg" -o -name "*.exe" -o -name "*.AppImage" | xargs ls -l 2>/dev/null | awk '$5 > 524288000' | wc -l)
        if [ $LARGE_PACKAGES -gt 0 ]; then
            TOTAL_SCORE=$((TOTAL_SCORE - 15))
            print_warning "$LARGE_PACKAGES large packages (>500MB) - Score: -15"
        fi
    fi
    
    # Final score interpretation
    print_info ""
    if [ $TOTAL_SCORE -ge 80 ]; then
        print_success "🎉 Bloat Score: $TOTAL_SCORE/100 - Excellent optimization!"
    elif [ $TOTAL_SCORE -ge 60 ]; then
        print_info "👍 Bloat Score: $TOTAL_SCORE/100 - Good optimization"
    elif [ $TOTAL_SCORE -ge 40 ]; then
        print_warning "⚠️  Bloat Score: $TOTAL_SCORE/100 - Some optimization needed"
    else
        print_error "🚨 Bloat Score: $TOTAL_SCORE/100 - Significant optimization required"
    fi
}

# Main execution
main() {
    analyze_node_modules
    echo ""
    analyze_dependencies
    echo ""
    analyze_build_output
    echo ""
    generate_recommendations
    echo ""
    generate_summary
    
    print_header "✅ BLOAT ANALYSIS COMPLETE"
    print_success "Analysis completed. Review recommendations above for optimization opportunities."
}

# Run main function
main "$@"