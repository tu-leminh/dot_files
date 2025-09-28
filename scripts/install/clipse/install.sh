#!/bin/bash
# Install script for clipse

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
    debug_log "Clipse install script started with DEBUG_MODE=true"
fi

show_progress "Installing clipse..."

# Check if we're on Ubuntu - can be extended to other distros
if ! grep -q "Ubuntu" /etc/os-release 2>/dev/null; then
    log_warning "This script is designed for Ubuntu systems."
    read -p "Continue anyway? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Install dependencies for Wayland support
show_progress "Installing Wayland clipboard utilities for clipse..."
if ! sudo -n apt install -y wl-clipboard > /dev/null 2>&1; then
    log_warning "Need sudo password to install wl-clipboard"
    if ! sudo apt install -y wl-clipboard > /dev/null 2>&1; then
        log_error "Failed to install wl-clipboard - clipse may not work properly on Wayland"
        exit 1
    fi
fi
log_success "wl-clipboard utilities installed successfully"

# Install clipse
show_progress "Installing clipse..."
if command -v go >/dev/null 2>&1; then
    # Install clipse using go install
    if ! go install github.com/savedra1/clipse@latest > /dev/null 2>&1; then
        log_error "Failed to install clipse via go install"
        exit 1
    else
        # Ensure GOPATH is set
        GOPATH=${GOPATH:-$HOME/go}
        CLIPSE_BIN="$GOPATH/bin/clipse"
        if [ -f "$CLIPSE_BIN" ]; then
            log_success "clipse installed successfully at $CLIPSE_BIN"
            
            # Make sure the clipse binary has execution permission
            chmod +x "$CLIPSE_BIN" > /dev/null 2>&1
            
            # Try to create a symlink to /usr/local/bin if possible
            if sudo -n ln -sf "$CLIPSE_BIN" /usr/local/bin/clipse > /dev/null 2>&1; then
                log_success "clipse made available system-wide"
            else
                # Add to user's .bashrc/.zshrc if not already done
                if ! grep -q 'export.*GOPATH.*bin' ~/.zshrc > /dev/null 2>&1; then
                    echo 'export PATH="$PATH:$GOPATH/bin"' >> ~/.zshrc
                    log_info "Added GOPATH/bin to PATH in ~/.zshrc"
                fi
                log_info "clipse available at $CLIPSE_BIN - ensure GOPATH/bin is in your PATH"
            fi
        else
            log_error "clipse binary not found at expected location: $CLIPSE_BIN"
        fi
    fi
else
    log_warning "Go is not installed, cannot install clipse. Please install Go first."
fi

show_progress "Clipse installation completed!"
log_info "Note: For Wayland systems, clipse requires wl-clipboard utilities to function properly"
log_info "Launch clipse with: clipse"
log_info "Run background listener with: clipse -listen"