# BOTS.md

This file is intended for bots and other automated tools to quickly understand the structure and purpose of this dotfiles repository.

## Repository Structure

*   `zsh/`: Contains the `.zshrc` file for Zsh configuration and plugins.
    *   `.zshrc`: Configures the Zsh shell with Oh My Posh theme, syntax highlighting, autosuggestions, and history search.
    *   `oh-my-posh-config.json`: Contains the Oh My Posh configuration using the wholespace theme.
    *   `plugins/`: Contains Zsh plugins for enhanced shell experience.
        *   `zsh-syntax-highlighting`: Provides syntax highlighting for commands as you type (cloned from https://github.com/zsh-users/zsh-syntax-highlighting.git).
        *   `zsh-autosuggestions`: Suggests commands based on history and completions (cloned from https://github.com/zsh-users/zsh-autosuggestions).
        *   `zsh-history-substring-search`: Allows searching through command history with arrow keys (cloned from https://github.com/zsh-users/zsh-history-substring-search).
*   `ranger/`: Contains the `rc.conf` file for `ranger` configuration.
    *   `rc.conf`: Configures the `ranger` file manager to show hidden files by default.
*   `tmux/`: Contains the `.tmux.conf` file for `tmux` configuration.
    *   `.tmux.conf`: Configures `tmux` to use Zsh as the default shell, adds Vim-like keybindings for copy mode, updates pane splitting to use - for horizontal splits and | for vertical splits, and adds Vim-style pane navigation with Ctrl+h/j/k/l.
*   `neovim/`: Contains the Neovim configuration as a submodule based on LazyVim.
*   `neovim_custom/`: Contains custom Neovim configurations that are tracked by the main repository.
*   `scripts/`: Contains scripts for managing the dotfiles.
    *   `unified_dotfiles_manager.sh`: A unified shell script that can install the latest versions of tools, apply dotfiles configurations, and test configurations. It replaces the functionality of all previous scripts with command-line options.
    *   `test_zsh_config.sh`: (Deprecated) A script to verify that the ZSH configuration loads correctly and all required files exist.
    *   `apply_configs.sh`: (Deprecated) A shell script that creates symlinks from the home directory to the dotfiles in this repository. It also manages the Neovim configuration.
    *   `install_latest_tools.sh`: (Deprecated) A shell script that installs the latest versions of nvim, ranger, tmux, and zsh on Ubuntu systems.
    *   `apply_configs_only.sh`: (Deprecated) A shell script that applies dotfiles configurations without installing tools.
    *   `setup_dotfiles.sh`: (Deprecated) A shell script that combines both the installation of latest tools and application of configurations.

## Zsh (Oh My Posh) Configuration

The Zsh configuration uses Oh My Posh with the wholespace theme as the prompt theme, providing a fast and customizable shell experience. The configuration includes:

*   Oh My Posh with wholespace theme for prompt customization
*   Syntax highlighting for commands as you type
*   Autosuggestions based on history and completions
*   History substring search with arrow keys

## Neovim (LazyVim) Configuration

The Neovim configuration is based on LazyVim, and it's included as a submodule in the `neovim` directory.

Custom configurations are stored in the `neovim_custom` directory, which is tracked by the main repository. The unified script symlinks the custom configuration files from `neovim_custom` into the `neovim` directory.

The main custom configuration files are:
*   `neovim_custom/lua/config/custom.lua`
*   `neovim_custom/lua/plugins/example.lua`

Custom plugins added:
*   Nordic theme (`AlexvZyl/nordic.nvim`)
*   Hardtime.nvim plugin (`m4xshen/hardtime.nvim`)

## Installation Process

To apply the configurations:

1. Clone the repository to your local machine
2. Initialize and update submodules: `git submodule update --init --recursive`
3. If you encounter issues with submodule initialization (especially with zsh plugins), you may need to manually clone them:
   ```bash
   cd ~/dot_files/zsh/plugins && rm -rf zsh-syntax-highlighting && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git
   cd ~/dot_files/zsh/plugins && rm -rf zsh-autosuggestions && git clone https://github.com/zsh-users/zsh-autosuggestions
   cd ~/dot_files/zsh/plugins && rm -rf zsh-history-substring-search && git clone https://github.com/zsh-users/zsh-history-substring-search
   ```
4. Run the `scripts/unified_dotfiles_manager.sh` script with your desired options:
   * For tools installation only: `./scripts/unified_dotfiles_manager.sh --install-tools`
   * For configuration application only: `./scripts/unified_dotfiles_manager.sh --apply-configs`
   * For configuration testing only: `./scripts/unified_dotfiles_manager.sh --test-config`
   * For both tools installation and configuration application: `./scripts/unified_dotfiles_manager.sh --all`
   * To also set zsh as default shell: `./scripts/unified_dotfiles_manager.sh --all --set-zsh-default`

Note: The script will automatically detect the repository location, making it portable across different systems.

## Application Versions Tracking

This repository installs the latest stable versions of key applications using the `scripts/unified_dotfiles_manager.sh` script. The currently installed versions are tracked here for reference:

*   **Neovim**: v0.11.4 (stable version)
*   **Zsh**: v5.8
*   **Ranger**: v1.9.4
*   **Tmux**: v3.5a
*   **Lazygit**: v0.55.0
*   **K9s**: v0.50.9
*   **Oh My Posh**: v26.23.3

Note: The script now installs the latest stable versions of all tools rather than locking to specific versions. These tracked versions are for reference purposes only.

For the submodules (plugins), specific commits are locked via Git submodules to ensure consistent behavior.

## Recent Improvements

The following improvements have been made to enhance code quality and reliability:

1. Fixed hardcoded paths in scripts to use dynamic path detection
2. Improved error handling in installation scripts to avoid redundant operations
3. Added proper logging and progress indicators to scripts
4. Added validation for symlinks in configuration application
5. Enhanced test scripts with better path handling
6. Merged all scripts into a single unified script with command-line options
7. Replaced Powerlevel10k with Oh My Posh for better maintainability
8. Updated Oh My Posh configuration to use the wholespace theme

## Updating BOTS.md

After making changes to the repository, please update this file to reflect the changes. This will help other bots and humans understand the repository.

When to update this file:

*   When you add a new configuration for a new tool.
*   When you add a new script.
*   When you change the directory structure.
*   When you change the purpose of a file or directory.
*   When you update the installed versions of applications (update the version tracking section).
*   When you deprecate or replace existing scripts with new ones.
*   When you add or modify Oh My Posh configurations.
*   When you add or modify test scripts.

Note: When scripts are deprecated or replaced, they should be marked as such in this file rather than immediately removed.

## Deprecated Scripts

The following scripts have been deprecated and replaced by the unified `unified_dotfiles_manager.sh` script:

*   `apply_configs.sh`: Replaced by `unified_dotfiles_manager.sh --apply-configs`
*   `install_latest_tools.sh`: Replaced by `unified_dotfiles_manager.sh --install-tools`
*   `apply_configs_only.sh`: Replaced by `unified_dotfiles_manager.sh --apply-configs`
*   `setup_dotfiles.sh`: Replaced by `unified_dotfiles_manager.sh --all`
*   `test_zsh_config.sh`: Replaced by `unified_dotfiles_manager.sh --test-config`

These scripts are kept for backward compatibility but will not be maintained going forward. Please use the new `unified_dotfiles_manager.sh` script instead.