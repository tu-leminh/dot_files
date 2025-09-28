#!/bin/bash
# Install script for neovim

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
    debug_log \"Neovim install script started with DEBUG_MODE=true"
fi

show_progress \"Installing latest stable Neovim..."
debug_log \"Checking if neovim is already installed\"
if command_exists nvim; then
    CURRENT_VERSION=$(nvim --version | head -n 1)
    debug_log \"Neovim is already installed: $CURRENT_VERSION"
    show_progress \"Neovim is already installed: $CURRENT_VERSION"
    # If already installed, we might still want to update, but for now just show this and continue
else
    debug_log \"Neovim is not installed, proceeding with installation from source\"
    # Install the latest stable version by compiling from source
    
    # Check if we're on Ubuntu - can be extended to other distros
if ! grep -q \"Ubuntu\" /etc/os-release 2>/dev/null; then
    log_warning \"This script is designed for Ubuntu systems.\"
    read -p \"Continue anyway? (y/n): \" -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Install build dependencies for Neovim
show_progress \"Installing build dependencies for Neovim...\"
if ! sudo -n apt install -y ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip > /dev/null 2>&1; then
    log_warning \"Need sudo password to install build dependencies for Neovim\"
    if ! sudo apt install -y ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip > /dev/null 2>&1; then
        log_error \"Failed to install build dependencies for Neovim\"
        exit 1
    fi
fi

# Clone the Neovim repository
show_progress \"Cloning Neovim repository...\"
cd /tmp
if [ -d \"neovim\" ]; then
    rm -rf neovim > /dev/null 2>&1
fi
git clone https://github.com/neovim/neovim.git > /dev/null 2>&1
cd neovim

# Get the latest stable release tag
show_progress \"Finding latest stable release...\"
LATEST_TAG=$(git tag -l --sort=-v:refname | grep -E '^v[0-9]+\\.[0-9]+\\.[0-9]+$' | head -n 1)
if [ -z \"$LATEST_TAG\" ]; then
    log_error \"Failed to find latest stable release tag\"
    exit 1
fi

show_progress \"Checking out latest stable release: $LATEST_TAG\"
git checkout \"$LATEST_TAG\" > /dev/null 2>&1

# Build and install Neovim
show_progress \"Building Neovim...\"
make CMAKE_BUILD_TYPE=Release > /dev/null 2>&1
show_progress \"Installing Neovim...\"
if ! sudo -n make install > /dev/null 2>&1; then
    log_warning \"Need sudo password to install Neovim\"
    if ! sudo make install > /dev/null 2>&1; then
        log_error \"Failed to install Neovim\"
        exit 1
    fi
fi

# Clean up
cd ..
rm -rf neovim > /dev/null 2>&1

if command_exists nvim; then
    NVIM_VERSION=$(nvim --version | head -n 1)
    log_success \"Neovim $NVIM_VERSION installed\"
fi  # Close the if statement that checks whether to install from source
fi

# Install LazyVim dependencies
show_progress \"Installing LazyVim dependencies (ripgrep, fzf, fd)...\"

if ! sudo -n apt install -y ripgrep fzf fd-find > /dev/null 2>&1; then
    log_warning \"Need sudo password to install LazyVim dependencies\"
    if ! sudo -S apt install -y ripgrep fzf fd-find > /dev/null 2>&1; then
        log_error \"Failed to install LazyVim dependencies\"
        exit 1
    fi
fi

# Create symlink for fd if needed (some systems use fdfind)
if command_exists fdfind && ! command_exists fd; then
    show_progress \"Creating fd symlink for fdfind...\"
    sudo ln -sf $(which fdfind) /usr/local/bin/fd > /dev/null 2>&1 || true
fi

# Verify LazyVim dependencies
if command_exists rg; then
    RG_VERSION=$(rg --version 2>&1 | head -n 1 | grep -oE '[0-9]+\\.[0-9]+\\.[0-9]+')
    log_success \"ripgrep $RG_VERSION installed\"
fi
if command_exists fzf; then
    FZF_VERSION=$(fzf --version 2>&1 | cut -d' ' -f1)
    log_success \"fzf $FZF_VERSION installed\"
fi
if command_exists fd || command_exists fdfind; then
    if command_exists fd; then
        FD_VERSION=$(fd --version 2>&1 | grep -oE '[0-9]+\\.[0-9]+\\.[0-9]+')
        log_success \"fd $FD_VERSION installed\"
    else
        FD_VERSION=$(fdfind --version 2>&1 | grep -oE '[0-9]+\\.[0-9]+\\.[0-9]+')
        log_success \"fdfind $FD_VERSION installed (as fd)\"
    fi
fi

show_progress \"Neovim installation completed!\"