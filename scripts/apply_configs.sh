#!/bin/bash
# Apply configurations module

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

# Apply configurations
apply_configs() {
    show_progress "Applying dotfiles configurations"
    
    # Initialize and update submodules
    show_progress "Initializing and updating submodules..."
    cd "$DOTFILES_DIR"
    if ! git submodule update --init --recursive > /dev/null 2>&1; then
        log_warning "Failed to initialize/update submodules"
    fi
    
    # Zsh
    create_symlink "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"

    # ranger
    create_symlink "$DOTFILES_DIR/ranger/rc.conf" "$HOME/.config/ranger/rc.conf"

    # tmux
    create_symlink "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"

    # Neovim
    create_symlink "$DOTFILES_DIR/neovim" "$HOME/.config/nvim"

    # Neovim custom config
    create_symlink "$DOTFILES_DIR/neovim_custom/lua/config/custom.lua" "$DOTFILES_DIR/neovim/lua/config/custom.lua"
    create_symlink "$DOTFILES_DIR/neovim_custom/lua/plugins/example.lua" "$DOTFILES_DIR/neovim/lua/plugins/example.lua"

    # Kitty terminal
    create_symlink "$DOTFILES_DIR/kitty" "$HOME/.config/kitty"
    
    # Mako notification daemon
    create_symlink "$DOTFILES_DIR/mako" "$HOME/.config/mako"
    
    # Wofi application launcher
    create_symlink "$DOTFILES_DIR/wofi" "$HOME/.config/wofi"

    # Sway
    create_symlink "$DOTFILES_DIR/sway/config" "$HOME/.config/sway/config"
    create_symlink "$DOTFILES_DIR/waybar" "$HOME/.config/waybar"

    show_progress "Dotfiles have been linked successfully!"
}