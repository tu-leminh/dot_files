#!/bin/bash
# This script creates symlinks from the home directory to the dotfiles in this repository.

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# Check if we're on Ubuntu (for compatibility with older versions)
if ! grep -q "Ubuntu" /etc/os-release 2>/dev/null; then
    echo "Warning: This script is designed for Ubuntu systems."
fi

# Zsh
ln -sf "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"

# ranger
mkdir -p "$HOME/.config/ranger"
ln -sf "$DOTFILES_DIR/ranger/rc.conf" "$HOME/.config/ranger/rc.conf"

# tmux
ln -sf "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"

# Neovim
mkdir -p "$HOME/.config"
ln -sf "$DOTFILES_DIR/neovim" "$HOME/.config/nvim"

# Neovim custom config
mkdir -p "$DOTFILES_DIR/neovim/lua/config"
mkdir -p "$DOTFILES_DIR/neovim/lua/plugins"

ln -sf "$DOTFILES_DIR/neovim_custom/lua/config/custom.lua" "$DOTFILES_DIR/neovim/lua/config/custom.lua"
ln -sf "$DOTFILES_DIR/neovim_custom/lua/plugins/example.lua" "$DOTFILES_DIR/neovim/lua/plugins/example.lua"

echo "Dotfiles have been linked successfully!"
