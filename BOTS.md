# BOTS.md

This file is intended for bots and other automated tools to quickly understand the structure and purpose of this dotfiles repository.

## Repository Structure

*   `zsh/`: Contains the `.zshrc` file for Zsh configuration and plugins.
    *   `.zshrc`: Configures the Zsh shell with Powerlevel10k theme, syntax highlighting, autosuggestions, and history search.
    *   `themes/powerlevel10k`: Contains the Powerlevel10k theme for Zsh.
    *   `plugins/`: Contains Zsh plugins for enhanced shell experience.
        *   `zsh-syntax-highlighting`: Provides syntax highlighting for commands as you type.
        *   `zsh-autosuggestions`: Suggests commands based on history and completions.
        *   `zsh-history-substring-search`: Allows searching through command history with arrow keys.
*   `lf/`: Contains the `lfrc` file for `lf` configuration.
    *   `lfrc`: Configures the `lf` file manager to show hidden files by default.
*   `ranger/`: Contains the `rc.conf` file for `ranger` configuration.
    *   `rc.conf`: Configures the `ranger` file manager to show hidden files by default.
*   `tmux/`: Contains the `.tmux.conf` file for `tmux` configuration.
    *   `.tmux.conf`: Configures `tmux` to use Zsh as the default shell and adds Vim-like keybindings for copy mode.
*   `neovim/`: Contains the Neovim configuration as a submodule based on LazyVim.
*   `neovim_custom/`: Contains custom Neovim configurations that are tracked by the main repository.
*   `scripts/`: Contains scripts for managing the dotfiles.
    *   `apply_configs.sh`: A shell script that creates symlinks from the home directory to the dotfiles in this repository. It also manages the Neovim configuration.

## Neovim (LazyVim) Configuration

The Neovim configuration is based on LazyVim, and it's included as a submodule in the `neovim` directory.

Custom configurations are stored in the `neovim_custom` directory, which is tracked by the main repository. The `scripts/apply_configs.sh` script symlinks the custom configuration files from `neovim_custom` into the `neovim` directory.

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
3. Run the `scripts/apply_configs.sh` script. This will create the necessary symlinks in your home directory and set up the Neovim configuration.

Note: The script assumes the repository is located at `/home/tule5/dot_files`. If you've cloned it elsewhere, you may need to adjust the paths in the script or move the repository to the expected location.

## Updating BOTS.md

After making changes to the repository, please update this file to reflect the changes. This will help other bots and humans understand the repository.

When to update this file:

*   When you add a new configuration for a new tool.
*   When you add a new script.
*   When you change the directory structure.
*   When you change the purpose of a file or directory.