#!/bin/bash
# Install script for zsh

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
    debug_log "ZSH install script started with DEBUG_MODE=true"
fi

show_progress "Installing zsh..."

# Check if we're on Ubuntu - can be extended to other distros
debug_log "Checking OS type from /etc/os-release"
if [ -f /etc/os-release ]; then
    debug_log "Reading OS information from /etc/os-release"
    . /etc/os-release
    debug_log "Detected OS: $NAME, VERSION_ID: $VERSION_ID"
    
    if ! grep -q "Ubuntu" /etc/os-release 2>/dev/null; then
        log_warning "This script is designed for Ubuntu systems. Detected: $NAME"
        read -p "Continue anyway? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            debug_log "User chose not to continue with non-Ubuntu system"
            exit 1
        fi
    else
        debug_log "Confirmed Ubuntu system, proceeding with installation"
    fi
else
    debug_log "Could not find /etc/os-release, checking with other methods"
    OS_NAME=$(uname -s)
    debug_log "System identified as: $OS_NAME"
    log_warning "This script is designed for Ubuntu systems. Detected: $OS_NAME"
    read -p "Continue anyway? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        debug_log "User chose not to continue with unidentifiable system"
        exit 1
    fi
fi

# Install latest zsh
show_progress "Installing latest zsh..."
debug_log "Checking if zsh is already installed"
if command_exists zsh; then
    CURRENT_VERSION=$(zsh --version | cut -d' ' -f2)
    debug_log "Zsh is already installed: $CURRENT_VERSION"
    show_progress "Zsh is already installed: $CURRENT_VERSION"
else
    debug_log "Zsh is not installed, attempting to install via apt with sudo -n"
    # Install the latest version available via apt
    if ! sudo -n apt install -y zsh > /dev/null 2>&1; then
        debug_log "sudo -n failed, need to request password"
        log_warning "Need sudo password to install zsh"
        if ! sudo -S apt install -y zsh > /dev/null 2>&1; then
            log_error "Failed to install zsh"
            debug_log "sudo -S also failed to install zsh"
            exit 1
        else
            debug_log "zsh installed successfully with sudo -S"
        fi
    else
        debug_log "zsh installed successfully with sudo -n"
    fi
fi

if command_exists zsh; then
    ZSH_VERSION=$(zsh --version 2>/dev/null | cut -d' ' -f2)
    debug_log "Zsh installation completed. Version detected: $ZSH_VERSION"
    log_success "zsh $ZSH_VERSION installed"
fi

if command_exists zsh; then
    ZSH_VERSION=$(zsh --version 2>/dev/null | cut -d' ' -f2)
    log_success "zsh $ZSH_VERSION installed"
fi

# Install Oh My Posh
show_progress "Installing Oh My Posh..."
debug_log "Installing Oh My Posh to $HOME/.local/bin"
# Create the target directory in user space to avoid permission issues
OMP_DIR="$HOME/.local/bin"
mkdir -p "$OMP_DIR" > /dev/null 2>&1
debug_log "Created directory $OMP_DIR"

# Download and install Oh My Posh
debug_log "Downloading and installing Oh My Posh from https://ohmyposh.dev/install.sh"
if curl -s https://ohmyposh.dev/install.sh | bash -s -- -d "$OMP_DIR" > /dev/null 2>&1; then
    debug_log "Oh My Posh installation script completed successfully"
    log_success "Oh My Posh installed successfully"
    
    # Check installed version
    if command_exists "$OMP_DIR/oh-my-posh"; then
        OMP_VERSION=$("$OMP_DIR/oh-my-posh" --version 2>/dev/null)
        debug_log "Oh My Posh version detected: $OMP_VERSION"
        log_success "Oh My Posh $OMP_VERSION installed"
    else
        debug_log "Oh My Posh command not found at $OMP_DIR/oh-my-posh"
    fi
else
    debug_log "Oh My Posh installation failed"
    log_warning "Failed to install Oh My Posh"
fi

if command_exists zsh; then
    ZSH_VERSION=$(zsh --version 2>/dev/null | cut -d' ' -f2)
    debug_log "Zsh installation completed. Version detected: $ZSH_VERSION"
    log_success "zsh $ZSH_VERSION installed"
fi

debug_log "Zsh installation process finished"
show_progress "Zsh installation completed!"