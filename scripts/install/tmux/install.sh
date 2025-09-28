#!/bin/bash
# Install script for tmux

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
    debug_log "Tmux install script started with DEBUG_MODE=true"
fi

show_progress "Installing latest tmux..."

# Check if we're on Ubuntu - can be extended to other distros
if ! grep -q "Ubuntu" /etc/os-release 2>/dev/null; then
    log_warning "This script is designed for Ubuntu systems."
    read -p "Continue anyway? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Install latest tmux
show_progress "Installing latest tmux..."
# Try to install via apt first
if ! sudo -n apt install -y tmux > /dev/null 2>&1; then
    log_warning "Need sudo password to install tmux"
    if ! sudo -S apt install -y tmux > /dev/null 2>&1; then
        log_error "Failed to install tmux"
        exit 1
    fi
fi
if command_exists tmux; then
    TMUX_VERSION=$(tmux -V 2>/dev/null | cut -d' ' -f2)
    log_success "tmux $TMUX_VERSION installed"
fi

show_progress "Tmux installation completed!"