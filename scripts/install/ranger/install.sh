#!/bin/bash
# Install script for ranger

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UTILS_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")/utils.sh"

if [ -f "$UTILS_DIR" ]; then
    source "$UTILS_DIR"
else
    echo "ERROR: utils.sh not found at $UTILS_DIR"
    exit 1
fi

# Set debug mode based on environment variable
if [ "$DEBUG_MODE" = true ]; then
    debug_log \"Ranger install script started with DEBUG_MODE=true\"
fi

debug_log \"Checking if ranger is already installed\"
if command_exists ranger; then
    CURRENT_VERSION=$(ranger --version 2>&1 | head -n 1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
    debug_log "Ranger is already installed: $CURRENT_VERSION"
    show_progress "Ranger is already installed: $CURRENT_VERSION"
    # Continue with installation to potentially upgrade
fi

show_progress "Installing latest ranger..."

# Check if we're on Ubuntu - can be extended to other distros
if ! grep -q "Ubuntu" /etc/os-release 2>/dev/null; then
    log_warning "This script is designed for Ubuntu systems."
    read -p "Continue anyway? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Install latest ranger
show_progress "Installing latest ranger..."
# Try to install via apt first, then fallback to pip
if ! sudo -n apt install -y ranger > /dev/null 2>&1; then
    log_warning \"Need sudo password to install ranger\"
    if ! sudo -S apt install -y ranger > /dev/null 2>&1; then
        log_warning \"Failed to install ranger via apt, trying pip...\"
        # Always install the latest version available via pip
        if ! pip3 install ranger-fm --upgrade --break-system-packages > /dev/null 2>&1; then
            # Try without break-system-packages flag
            pip3 install ranger-fm --upgrade > /dev/null 2>&1
        fi
    fi
fi
if command_exists ranger; then
    RANGER_VERSION=$(ranger --version 2>&1 | head -n 1 | grep -oE '[0-9]+\\.[0-9]+\\.[0-9]+')
    log_success \"ranger $RANGER_VERSION installed\"
fi

show_progress \"Ranger installation completed!\"