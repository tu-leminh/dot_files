# Installation Guide

This document provides detailed instructions for installing and using these dotfiles.

## Prerequisites

Before installing these dotfiles, ensure you have the following tools installed:
- Git
- Zsh (optional, but recommended)
- Neovim (optional)
- tmux (optional)
- ranger or lf (optional)

## Installation Steps

1. Clone the repository:
   ```
   git clone https://github.com/tu-leminh/dot_files.git ~/dot_files
   ```

2. Navigate to the repository directory:
   ```
   cd ~/dot_files
   ```

3. Initialize and update submodules:
   ```
   git submodule update --init --recursive
   ```

4. Make the installation script executable:
   ```
   chmod +x scripts/apply_configs.sh
   ```

5. Run the installation script:
   ```
   ./scripts/apply_configs.sh
   ```

## What Gets Installed

The installation script will create symbolic links in your home directory for the following tools:

- Zsh configuration (`.zshrc`)
- tmux configuration (`.tmux.conf`)
- Neovim configuration (`.config/nvim`)
- ranger configuration (`.config/ranger/rc.conf`)
- lf configuration (`.config/lf/lfrc`)

## Customization

You can customize the configurations by modifying the files in their respective directories. The changes will be reflected in your environment since the files are symlinked.

## Troubleshooting

If you encounter any issues during installation:

1. Ensure all prerequisites are installed
2. Check that you have proper permissions in your home directory
3. Verify that the paths in `scripts/apply_configs.sh` match your repository location

If you need to reinstall or update the configurations, simply run the `apply_configs.sh` script again.