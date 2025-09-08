# BOTS.md

This file is intended for bots and other automated tools to quickly understand the structure and purpose of this dotfiles repository.

## Repository Structure

*   `zsh/`: Contains the `.zshrc` file for Zsh configuration.
    *   `.zshrc`: Configures the Zsh shell.
    *   `themes/powerlevel10k`: Contains the Powerlevel10k theme for Zsh.
*   `lf/`: Contains the `lfrc` file for `lf` configuration.
    *   `lfrc`: Configures the `lf` file manager to show hidden files by default.
*   `ranger/`: Contains the `rc.conf` file for `ranger` configuration.
    *   `rc.conf`: Configures the `ranger` file manager to show hidden files by default.
*   `tmux/`: Contains the `.tmux.conf` file for `tmux` configuration.
    *   `.tmux.conf`: Configures `tmux` to use Zsh as the default shell.
*   `scripts/`: Contains scripts for managing the dotfiles.
    *   `apply_configs.sh`: A shell script that creates symlinks from the home directory to the dotfiles in this repository. It also manages the Neovim configuration.

## Neovim (LazyVim) Configuration

The Neovim configuration is based on LazyVim. The `apply_configs.sh` script automatically fetches the latest version of the [LazyVim starter template](https://github.com/LazyVim/starter) and sets it up.

Custom configurations can be added to `neovim/lua/config/custom.lua`.

## Usage

To apply the configurations, run the `scripts/apply_configs.sh` script. This will create the necessary symlinks in your home directory and set up the Neovim configuration.

## Updating BOTS.md

After making changes to the repository, please update this file to reflect the changes. This will help other bots and humans understand the repository.

When to update this file:

*   When you add a new configuration for a new tool.
*   When you add a new script.
*   When you change the directory structure.
*   When you change the purpose of a file or directory.