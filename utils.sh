#!/bin/bash
# ============================================
# SENTINEL - Main Installation Script
# ============================================

set -euo pipefail

# Colors
RED='\033[0;31m'
GRN='\033[0;32m'
YLW='\033[0;33m'
BLU='\033[0;34m'
RST='\033[0m'

# Detect environment
detect_env() {
    if [[ -d "/data/data/com.termux" ]] || [[ -n "${TERMUX_VERSION:-}" ]]; then
        IS_TERMUX=1
        NEED_ROOT=0
        echo -e "${GRN}[✓] Termux environment detected (no root required)${RST}"
    else
        IS_TERMUX=0
        if [[ $EUID -eq 0 ]]; then
            NEED_ROOT=1
            echo -e "${GRN}[✓] Linux environment detected (running as root)${RST}"
        else
            NEED_ROOT=1
            echo -e "${YLW}[!] Linux environment detected (root privileges required)${RST}"
            echo -e "${YLW}[!] Please run with: sudo $0${RST}"
            exit 1
        fi
    fi
}

# Create directory structure
create_dirs() {
    local base_dir="${HOME}/sentinel"
    mkdir -p "$base_dir"/{core,modules,data,logs,run,bin}
    echo "$base_dir"
}

# Main installation
main() {
    echo -e "${BLU}╔════════════════════════════════════════╗${RST}"
    echo -e "${BLU}║   SENTINEL Security Suite Installer    ║${RST}"
    echo -e "${BLU}╚════════════════════════════════════════╝${RST}"
    echo
    
    detect_env
    local base_dir
    base_dir=$(create_dirs)
    
    echo -e "${GRN}[✓] Installing to: ${base_dir}${RST}"
    
    # Download and setup all components
    cd "$base_dir"
    
    # Create all files (will be done in subsequent scripts)
    echo -e "${GRN}[✓] Installation complete!${RST}"
    echo -e "${YLW}[i] Run: cd ${base_dir} && ./sentinel start${RST}"
}

main "$@"