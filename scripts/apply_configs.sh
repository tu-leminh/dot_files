#!/bin/bash
# This script creates symlinks from the home directory to the dotfiles in this repository.

# Zsh
ln -sf "/home/tule5/dot_files/zsh/.zshrc" "$HOME/.zshrc"

# lf
mkdir -p "$HOME/.config/lf"
ln -sf "/home/tule5/dot_files/lf/lfrc" "$HOME/.config/lf/lfrc"

# ranger
mkdir -p "$HOME/.config/ranger"
ln -sf "/home/tule5/dot_files/ranger/rc.conf" "$HOME/.config/ranger/rc.conf"

# tmux
ln -sf "/home/tule5/dot_files/tmux/.tmux.conf" "$HOME/.tmux.conf"

# Neovim
mkdir -p "$HOME/.config"
ln -sf "/home/tule5/dot_files/neovim" "$HOME/.config/nvim"

# Neovim custom config
ln -sf "/home/tule5/dot_files/neovim_custom/lua/config/custom.lua" "/home/tule5/dot_files/neovim/lua/config/custom.lua"
ln -sf "/home/tule5/dot_files/neovim_custom/lua/plugins/example.lua" "/home/tule5/dot_files/neovim/lua/plugins/example.lua"
