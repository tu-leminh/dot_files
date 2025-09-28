#!/bin/bash
# Install script for sway

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
    debug_log "Sway install script started with DEBUG_MODE=true"
fi

show_progress "Installing Sway and related packages..."

# Check if we're on Ubuntu - can be extended to other distros
if ! grep -q "Ubuntu" /etc/os-release 2>/dev/null; then
    log_warning "This script is designed for Ubuntu systems."
    read -p "Continue anyway? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Check if Sway is already installed
SWAY_INSTALLED=false
if command -v sway >/dev/null 2>&1 || command -v Sway >/dev/null 2>&1; then
    log_info "Sway is already installed"
    SWAY_INSTALLED=true
    log_info "Skipping Sway installation (already installed)"
fi

if [[ "$SWAY_INSTALLED" == false ]]; then
    # Install Sway and related packages
    show_progress "Installing Sway and related packages..."
    if ! sudo -n apt install -y sway mako-notifier grim slurp brightnessctl pamixer playerctl thunar foot wmenu > /dev/null 2>&1; then
        log_warning "Need sudo password to install Sway and related packages"
        if sudo apt install -y sway mako-notifier grim slurp brightnessctl pamixer playerctl thunar foot wmenu > /dev/null 2>&1; then
            log_success "Sway and related packages installed successfully"
        else
            log_error "Failed to install Sway packages"
            exit 1
        fi
    else
        log_success "Sway and related packages installed successfully"
    fi
fi

show_progress "Sway installation completed!"