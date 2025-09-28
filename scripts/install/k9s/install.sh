#!/bin/bash
# Install script for k9s

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
    debug_log "K9s install script started with DEBUG_MODE=true"
fi

show_progress \"Installing k9s...\"

# Check if we're on Ubuntu - can be extended to other distros
if ! grep -q \"Ubuntu\" /etc/os-release 2>/dev/null; then
    log_warning \"This script is designed for Ubuntu systems.\"
    read -p \"Continue anyway? (y/n): \" -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Install k9s (latest stable release)
cd /tmp
K9S_URL=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | grep browser_download_url | grep Linux_amd64 | head -n 1 | cut -d '\"' -f 4)
if [ -z \"$K9S_URL\" ]; then
    log_warning \"Failed to find k9s download URL, trying alternative method...\"
    # Alternative method using the GitHub releases page directly
    K9S_VERSION=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | grep tag_name | cut -d '\"' -f 4 | sed 's/v//')
    if [ -z \"$K9S_VERSION\" ]; then
        log_error \"Failed to determine k9s version\"
        exit 1
    fi
    K9S_URL=\"https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/k9s_Linux_amd64.tar.gz\"
fi

show_progress \"Downloading k9s from: $K9S_URL\"
if ! wget \"$K9S_URL\" -O k9s.tar.gz > /dev/null 2>&1; then
    log_error \"Failed to download k9s\"
    exit 1
fi

tar xzf k9s.tar.gz k9s > /dev/null 2>&1
if ! sudo -n install k9s /usr/local/bin > /dev/null 2>&1; then
    log_warning \"Need sudo password to install k9s\"
    if ! sudo install k9s /usr/local/bin > /dev/null 2>&1; then
        log_error \"Failed to install k9s\"
        exit 1
    fi
fi
rm k9s.tar.gz k9s > /dev/null 2>&1

# Check installed version
if command_exists k9s; then
    K9S_VERSION_OUTPUT=$(k9s version 2>&1)
    K9S_VERSION=$(echo \"$K9S_VERSION_OUTPUT\" | grep Version | grep -oE '[0-9]+\\.[0-9]+\\.[0-9]+' || echo \"\")
    if [ -z \"$K9S_VERSION\" ]; then
        # Try alternative format
        K9S_VERSION=$(echo \"$K9S_VERSION_OUTPUT\" | head -n 1 | grep -oE '[0-9]+\\.[0-9]+\\.[0-9]+' || echo \"unknown\")
    fi
    log_success \"k9s $K9S_VERSION installed\"
else
    log_success \"k9s installed\"
fi

show_progress \"K9s installation completed!\"