#!/bin/bash
# Common utility functions for dotfiles management

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Debug and silent mode flags
DEBUG_MODE=${DEBUG_MODE:-false}
SILENT_MODE=${SILENT_MODE:-true}

# Debug logging function
debug_log() {
    if [ "$DEBUG_MODE" = true ]; then
        echo -e "[DEBUG $(date +'%Y-%m-%d %H:%M:%S')] $1" >&2
    fi
}

# Function to detect OS
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
        VER=$VERSION_ID
    else
        OS=$(uname -s)
        VER=$(uname -r)
    fi
    
    echo "$OS" | tr '[:upper:]' '[:lower:]'
}

# Function to detect Ubuntu version
detect_ubuntu_version() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [ "$NAME" = "Ubuntu" ]; then
            echo "$VERSION_ID"
            return 0
        fi
    fi
    return 1
}

# Function to detect Debian version
detect_debian_version() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [ "$NAME" = "Debian GNU/Linux" ]; then
            echo "$VERSION_ID"
            return 0
        fi
    fi
    return 1
}

# Function to detect Fedora version
detect_fedora_version() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [ "$NAME" = "Fedora Linux" ]; then
            echo "$VERSION_ID"
            return 0
        fi
    fi
    return 1
}

# Function to detect Arch version
detect_arch_version() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [ "$NAME" = "Arch Linux" ]; then
            echo "rolling"
            return 0
        fi
    fi
    return 1
}

# Progress tracking
show_progress() {
    if [ "$SILENT_MODE" = true ]; then
        echo -e "${BLUE}>>> $1${NC}" >&2
    fi
}

# Logging functions
log() {
    # Only log errors in silent mode, otherwise show all messages
    if [ "$SILENT_MODE" = false ]; then
        echo -e "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
    fi
}

log_info() {
    # Only log errors in silent mode
    if [ "$SILENT_MODE" = false ]; then
        log "${BLUE}INFO${NC}: $1"
    fi
}

log_success() {
    # Only log errors in silent mode
    if [ "$SILENT_MODE" = false ]; then
        log "${GREEN}SUCCESS${NC}: $1"
    fi
}

log_warning() {
    # Only log errors in silent mode
    if [ "$SILENT_MODE" = false ]; then
        log "${YELLOW}WARNING${NC}: $1"
    fi
}

log_error() {
    # Always print errors
    echo -e "[$(date +'%Y-%m-%d %H:%M:%S')] ${RED}ERROR${NC}: $1" >&2
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to compare version strings
version_gt() {
    test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1"
}

# Function to create symlink with validation
create_symlink() {
    local source="$1"
    local target="$2"
    
    # Check if source file exists
    if [ ! -f "$source" ] && [ ! -d "$source" ]; then
        log_warning "Source $source does not exist"
        return 1
    fi
    
    # Create target directory if it doesn't exist
    local target_dir=$(dirname "$target")
    if [ ! -d "$target_dir" ]; then
        mkdir -p "$target_dir" > /dev/null 2>&1
    fi
    
    # Check if target is already a symlink pointing to the correct source
    if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
        log_info "Symlink already exists and is correct: $target -> $source"
        return 0
    fi
    
    # Create symlink
    if ln -sf "$source" "$target" > /dev/null 2>&1; then
        log_success "Created symlink: $target -> $source"
        return 0
    else
        log_error "Failed to create symlink $target -> $source"
        return 1
    fi
}

# Validate and set script and dotfiles directories
validate_directories() {
    # Use the already set SCRIPT_DIR if available, otherwise calculate from BASH_SOURCE
    local script_dir
    if [ -n "$SCRIPT_DIR" ]; then
        script_dir="$SCRIPT_DIR"
    else
        script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    fi
    
    local dotfiles_dir="$(dirname "$script_dir")"
    
    # Export these variables
    export SCRIPT_DIR="$script_dir"
    export DOTFILES_DIR="$dotfiles_dir"
    
    # Verify directories exist
    if [ ! -d "$SCRIPT_DIR" ]; then
        log_error "Script directory does not exist: $SCRIPT_DIR"
        return 1
    fi
    
    if [ ! -d "$DOTFILES_DIR" ]; then
        log_error "Dotfiles directory does not exist: $DOTFILES_DIR"
        return 1
    fi
}