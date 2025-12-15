#!/bin/bash
# AudioDUPER - Electron Build & Distribution Script
# Uses electron-builder to produce platform-specific packages

set -e

# ── Colors & formatting ──────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

ts() { date +'%H:%M:%S'; }
info()    { echo -e "${BLUE}[$(ts)]${NC} $1"; }
success() { echo -e "${GREEN}[$(ts)] OK${NC} $1"; }
warn()    { echo -e "${YELLOW}[$(ts)] !!${NC} $1"; }
fail()    { echo -e "${RED}[$(ts)] FAIL${NC} $1"; }
header()  { echo -e "\n${CYAN}${BOLD}── $1 ──${NC}"; }

# ── Project root ─────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR/.."
cd "$PROJECT_DIR"

# ── Defaults ─────────────────────────────────────────────────────────
PLATFORM="linux"
ARCH="x64"
QUICK=false
NO_CLEAN=false
BUILD_START=0

# ── Trap: cleanup on unexpected exit ─────────────────────────────────
cleanup() {
    local exit_code=$?
    if [ $exit_code -ne 0 ] && [ $BUILD_START -ne 0 ]; then
        echo ""
        fail "Build failed with exit code $exit_code"
        elapsed=$(( $(date +%s) - BUILD_START ))
        info "Elapsed: ${elapsed}s"
    fi
}
trap cleanup EXIT

# ── Usage ────────────────────────────────────────────────────────────
usage() {
    cat <<EOF
AudioDUPER Build Script

Usage: $(basename "$0") [OPTIONS]

Options:
  --platform <mac|win|linux|all>   Target platform (default: linux)
  --arch <x64|arm64>               Target architecture (default: x64)
  --quick                          Skip cleanup and lint
  --no-clean                       Skip cleaning dist/ and build-temp/
  --help                           Show this help

Examples:
  $(basename "$0")                         # Linux x64 build
  $(basename "$0") --platform mac          # macOS build (x64 + arm64)
  $(basename "$0") --platform all          # Build for all platforms
  $(basename "$0") --quick                 # Fast rebuild, no cleanup
EOF
    exit 0
}

# ── Parse CLI args ───────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
    case $1 in
        --platform)  PLATFORM="$2"; shift 2 ;;
        --arch)      ARCH="$2"; shift 2 ;;
        --quick)     QUICK=true; shift ;;
        --no-clean)  NO_CLEAN=true; shift ;;
        --help)      usage ;;
        *)           fail "Unknown option: $1"; usage ;;
    esac
done

# Validate platform
case $PLATFORM in
    mac|win|linux|all) ;;
    *) fail "Invalid platform: $PLATFORM (use mac/win/linux/all)"; exit 1 ;;
esac

# Validate arch
case $ARCH in
    x64|arm64) ;;
    *) fail "Invalid arch: $ARCH (use x64/arm64)"; exit 1 ;;
esac

# ── Use all CPU cores ────────────────────────────────────────────────
export ELECTRON_BUILDER_PARALLELISM=$(nproc)

# ── Start ────────────────────────────────────────────────────────────
BUILD_START=$(date +%s)
echo ""
echo -e "${CYAN}${BOLD}AudioDUPER Build${NC}"
echo -e "${CYAN}Platform: ${BOLD}$PLATFORM${NC}  Arch: ${BOLD}$ARCH${NC}  Cores: ${BOLD}$(nproc)${NC}"
echo ""

# ── Phase 1: Requirements ───────────────────────────────────────────
header "Phase 1: Requirements Check"

MISSING=0
for cmd in node npm npx; do
    if command -v "$cmd" &>/dev/null; then
        success "$cmd $(command $cmd --version 2>/dev/null | head -1)"
    else
        fail "$cmd not found"
        MISSING=1
    fi
done

# Check electron-builder
if npx electron-builder --version &>/dev/null; then
    success "electron-builder $(npx electron-builder --version 2>/dev/null)"
else
    fail "electron-builder not available (install with: npm i -D electron-builder)"
    MISSING=1
fi

if [ $MISSING -ne 0 ]; then
    fail "Missing required tools. Install them and retry."
    exit 1
fi

# ── Phase 2: Clean ───────────────────────────────────────────────────
if [ "$NO_CLEAN" = false ] && [ "$QUICK" = false ]; then
    header "Phase 2: Clean Previous Artifacts"
    for dir in dist build-temp; do
        if [ -d "$dir" ]; then
            rm -rf "$dir"
            info "Removed $dir/"
        fi
    done
    success "Clean complete"
else
    info "Skipping clean (--no-clean or --quick)"
fi

# ── Phase 3: Dependencies ───────────────────────────────────────────
header "Phase 3: Dependencies"

if [ ! -d "node_modules" ]; then
    info "Installing dependencies..."
    npm install
    success "npm install complete"
else
    success "node_modules present"
fi

# ── Phase 4: Lint ────────────────────────────────────────────────────
if [ "$QUICK" = false ]; then
    header "Phase 4: Lint Check"
    if npm run lint 2>/dev/null; then
        success "ESLint passed"
    else
        warn "ESLint reported issues (non-blocking, continuing)"
    fi
else
    info "Skipping lint (--quick)"
fi

# ── Phase 5: electron-builder ────────────────────────────────────────
header "Phase 5: Building Distribution"

run_builder() {
    local plat="$1"
    info "Building for $plat..."

    case $plat in
        linux)
            npx electron-builder --linux deb AppImage --${ARCH}
            ;;
        mac)
            npx electron-builder --mac dmg --x64 --arm64
            ;;
        win)
            npx electron-builder --win nsis --${ARCH}
            ;;
    esac
}

case $PLATFORM in
    all)
        run_builder linux
        run_builder mac
        run_builder win
        ;;
    *)
        run_builder "$PLATFORM"
        ;;
esac

success "electron-builder finished"

# ── Phase 6: Build Results ───────────────────────────────────────────
header "Phase 6: Build Results"

if [ -d "dist" ]; then
    echo ""
    printf "${BOLD}%-60s %10s${NC}\n" "FILE" "SIZE"
    printf "%-60s %10s\n" "------------------------------------------------------------" "----------"

    # List output files (skip directories and blockmap files)
    find dist -maxdepth 2 -type f \
        ! -name "*.blockmap" \
        ! -name "builder-debug.yml" \
        ! -name "builder-effective-config.yaml" \
        -printf '%s %p\n' 2>/dev/null | sort -k2 | while read size filepath; do
        filename=$(basename "$filepath")
        if [ $size -ge 1073741824 ]; then
            human=$(awk "BEGIN {printf \"%.1f GB\", $size/1073741824}")
        elif [ $size -ge 1048576 ]; then
            human=$(awk "BEGIN {printf \"%.1f MB\", $size/1048576}")
        elif [ $size -ge 1024 ]; then
            human=$(awk "BEGIN {printf \"%.1f KB\", $size/1024}")
        else
            human="${size} B"
        fi
        printf "  %-58s %10s\n" "$filename" "$human"
    done

    echo ""
    TOTAL=$(du -sh dist 2>/dev/null | cut -f1)
    info "Total dist size: $TOTAL"
else
    warn "dist/ directory not found"
fi

# ── Summary ──────────────────────────────────────────────────────────
elapsed=$(( $(date +%s) - BUILD_START ))
mins=$((elapsed / 60))
secs=$((elapsed % 60))

echo ""
echo -e "${GREEN}${BOLD}Build complete in ${mins}m ${secs}s${NC}"
echo -e "  Platform: $PLATFORM | Arch: $ARCH | Cores: $(nproc)"
echo -e "  Output:   $(pwd)/dist/"
echo ""
