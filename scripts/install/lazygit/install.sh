#!/bin/bash
# Install script for lazygit

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
    debug_log \"Lazygit install script started with DEBUG_MODE=true\"
fi

show_progress \"Installing lazygit...\"

# Check if we're on Ubuntu - can be extended to other distros
if ! grep -q \"Ubuntu\" /etc/os-release 2>/dev/null; then
    log_warning \"This script is designed for Ubuntu systems.\"
    read -p \"Continue anyway? (y/n): \" -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

LAZYGIT_URL=\"\"
if command_exists curl; then
    LAZYGIT_URL=$(curl -s \"https://api.github.com/repos/jesseduffield/lazygit/releases/latest\" | grep \"browser_download_url.*Linux_x86_64.tar.gz\" | cut -d '\"' -f 4)
fi

if [ -n \"$LAZYGIT_URL\" ]; then
    show_progress \"Downloading lazygit from: $LAZYGIT_URL\"
    # Use home directory for downloads to avoid permission issues
    if curl -s -L \"$LAZYGIT_URL\" -o \"$HOME/lazygit.tar.gz\" > /dev/null 2>&1; then
        # Extract to home directory first
        if tar -xzf \"$HOME/lazygit.tar.gz\" -C \"$HOME\" > /dev/null 2>&1; then
            # Try sudo install first
            if sudo install \"$HOME/lazygit\" \"/usr/local/bin/\" > /dev/null 2>&1; then
                rm -f \"$HOME/lazygit\" \"$HOME/lazygit.tar.gz\"
                LAZYGIT_VERSION=$(lazygit version 2>&1 | head -n 1 | grep -oE '[0-9]+\\.[0-9]+\\.[0-9]+')
                log_success \"lazygit $LAZYGIT_VERSION installed\"
            else
                # Try installing to ~/.local/bin if sudo fails
                mkdir -p \"$HOME/.local/bin\"
                if install \"$HOME/lazygit\" \"$HOME/.local/bin/\" > /dev/null 2>&1; then
                    rm -f \"$HOME/lazygit\" \"$HOME/lazygit.tar.gz\"
                    LAZYGIT_VERSION=$(lazygit version 2>&1 | head -n 1 | grep -oE '[0-9]+\\.[0-9]+\\.[0-9]+')
                    log_success \"lazygit $LAZYGIT_VERSION installed\"
                else
                    log_warning \"Failed to install lazygit to $HOME/.local/bin\"
                    rm -f \"$HOME/lazygit\" \"$HOME/lazygit.tar.gz\"
                fi
            fi
        else
            log_warning \"Failed to extract lazygit archive\"
            rm -f \"$HOME/lazygit.tar.gz\"
        fi
    else
        log_warning \"Failed to download lazygit\"
    fi
else
    log_warning \"Failed to find lazygit download URL\"
fi

show_progress \"Lazygit installation completed!\"