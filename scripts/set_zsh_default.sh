#!/bin/bash
# Set zsh as default shell module

# Source utility functions
# Note: SCRIPT_DIR is expected to be set by the main script before sourcing this module
if [ -n "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/utils.sh" ]; then
    source "$SCRIPT_DIR/utils.sh"
elif [ -f "$(dirname "${BASH_SOURCE[0]}")/utils.sh" ]; then
    source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"
else
    echo "Error: utils.sh not found!" >&2
    exit 1
fi

# Function to set zsh as default shell
set_zsh_default() {
    show_progress "Setting zsh as default shell"
    # Check if we're running interactively
    if [ -t 0 ]; then
        read -p "Do you want instructions to set zsh as your default shell? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            log_info "To set zsh as your default shell, run the following command:"
            echo "    chsh -s /usr/bin/zsh" >&2
            log_info "You will be prompted to enter your password."
            log_info "After running this command, log out and back in for the changes to take effect."
        fi
    else
        # Non-interactive mode - just provide the instructions
        log_info "To set zsh as your default shell, run the following command:"
        echo "    chsh -s /usr/bin/zsh" >&2
        log_info "You will be prompted to enter your password."
        log_info "After running this command, log out and back in for the changes to take effect."
    fi
}