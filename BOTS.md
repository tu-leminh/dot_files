# BOTS.md

This file is intended for bots and other automated tools to quickly understand the structure and purpose of this dotfiles repository.

## Repository Structure

*   `zsh/`: Contains the `.zshrc` file for Zsh configuration and plugins.
    *   `.zshrc`: Configures the Zsh shell with Oh My Posh theme, syntax highlighting, autosuggestions, and history search.
    *   `oh-my-posh-config.json`: Contains the Oh My Posh configuration using the wholespace theme.
    *   `plugins/`: Contains Zsh plugins for enhanced shell experience.
        *   `zsh-syntax-highlighting`: Provides syntax highlighting for commands as you type.
        *   `zsh-autosuggestions`: Suggests commands based on history and completions.
        *   `zsh-history-substring-search`: Allows searching through command history with arrow keys.
*   `ranger/`: Contains the `rc.conf` file for `ranger` configuration.
    *   `rc.conf`: Configures the `ranger` file manager to show hidden files by default.
*   `tmux/`: Contains the `.tmux.conf` file for `tmux` configuration.
    *   `.tmux.conf`: Configures `tmux` with Vim-like keybindings and navigation.
*   `neovim/`: Contains the Neovim configuration as a submodule based on LazyVim.
*   `neovim_custom/`: Contains custom Neovim configurations that are tracked by the main repository.
*   `scripts/`: Contains scripts for managing the dotfiles.
    *   `unified_dotfiles_manager.sh`: A unified shell script that handles all dotfiles management tasks.

## Zsh Configuration

The Zsh configuration uses Oh My Posh with the wholespace theme, providing:
*   Custom prompt theme
*   Syntax highlighting for commands as you type
*   Autosuggestions based on history and completions
*   History substring search with arrow keys

Key files:
*   `zsh/.zshrc`: Main configuration file
*   `zsh/oh-my-posh-config.json`: Oh My Posh theme configuration
*   `zsh/plugins/`: Directory containing Zsh plugins as Git submodules

Important functions in .zshrc:
*   Oh My Posh initialization
*   Plugin loading (syntax highlighting, autosuggestions, history search)
*   Key bindings configuration
*   Alias definitions
*   Tmux auto-start function

## Neovim Configuration

The Neovim configuration is based on LazyVim as a submodule. Custom configurations are stored in `neovim_custom/` and symlinked by the unified script.

Custom plugins:
*   Nordic theme (`AlexvZyl/nordic.nvim`)
*   Hardtime.nvim plugin (`m4xshen/hardtime.nvim`)

Key files:
*   `neovim/`: Main Neovim configuration (LazyVim submodule)
*   `neovim_custom/lua/config/custom.lua`: Custom configuration file
*   `neovim_custom/lua/plugins/example.lua`: Custom plugins configuration

## Tmux Configuration

Tmux is configured with Vim-like keybindings for pane navigation and improved splitting commands.

Key files:
*   `tmux/.tmux.conf`: Main tmux configuration file

Configuration details:
*   Uses Zsh as default shell
*   Vim-like keybindings for copy mode
*   Pane splitting: `-` for horizontal, `|` for vertical
*   Pane navigation: `Ctrl+h/j/k/l`
*   No confirmation prompts for closing windows/panes (`x` and `X` keys)

## Ranger Configuration

Ranger is configured to show hidden files by default.

Key files:
*   `ranger/rc.conf`: Main ranger configuration file

## Installation Process

1. Clone the repository and initialize submodules: `git submodule update --init --recursive`
2. Run the unified script with desired options:
   * Install tools only: `./scripts/unified_dotfiles_manager.sh --install-tools`
   * Apply configurations only: `./scripts/unified_dotfiles_manager.sh --apply-configs`
   * Test configuration: `./scripts/unified_dotfiles_manager.sh --test-config`
   * Install tools and apply configurations: `./scripts/unified_dotfiles_manager.sh --all`
   * Also set zsh as default shell: `./scripts/unified_dotfiles_manager.sh --all --set-zsh-default`

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

## Unified Dotfiles Manager Script

This is the only script maintained for dotfiles management. It provides:

### Usage
```bash
./scripts/unified_dotfiles_manager.sh [OPTIONS]

Options:
  -i, --install-tools    Install the latest versions of tools
  -c, --apply-configs    Apply dotfiles configurations (create symlinks)
  -t, --test-config      Test ZSH configuration
  -a, --all              Install tools and apply configurations
  -z, --set-zsh-default  Set zsh as the default shell
  -h, --help             Show this help message
```

### Key Functions
*   `install_tools()`: Installs latest versions of all tools
*   `apply_configs()`: Creates symlinks for all dotfiles
*   `test_config()`: Tests ZSH configuration
*   `create_symlink()`: Creates validated symlinks
*   `set_zsh_default()`: Sets zsh as default shell (requires password authentication)

### Environment Variables
*   `SCRIPT_DIR`: Directory where the script is located
*   `DOTFILES_DIR`: Root directory of the dotfiles repository

### Setting Zsh as Default Shell

To enable the tmux auto-start feature, zsh must be set as the default shell since the tmux auto-start logic is in the `.zshrc` file.

Run: `./scripts/unified_dotfiles_manager.sh --set-zsh-default`

Note: This requires password authentication. If the script fails due to authentication, run manually:
`chsh -s /usr/bin/zsh`

After changing the default shell, log out and log back in for the changes to take effect.

## Auto Tmux Startup

Tmux automatically starts for all interactive terminal sessions (not just SSH) through the `.zshrc` configuration:

```bash
# Auto-start tmux for all terminal sessions
if command -v tmux >/dev/null 2>&1; then
    if [[ $- == *i* ]] && [[ -z "$TMUX" ]]; then
        tmux attach-session -t main 2>/dev/null || tmux new-session -s main
    fi
fi
```

Session name: `main`

### Dependency on Zsh as Default Shell

The tmux auto-start feature requires zsh to be set as the default shell since the logic is implemented in the `.zshrc` file. If bash or another shell is the default, this feature will not work.

To enable this feature:
1. Run: `./scripts/unified_dotfiles_manager.sh --set-zsh-default`
2. Log out and log back in for the changes to take effect

## Symlink Structure

The unified script creates the following symlinks:
*   `~/.zshrc` -> `zsh/.zshrc`
*   `~/.config/ranger/rc.conf` -> `ranger/rc.conf`
*   `~/.tmux.conf` -> `tmux/.tmux.conf`
*   `~/.config/nvim` -> `neovim/`
*   `neovim/lua/config/custom.lua` -> `neovim_custom/lua/config/custom.lua`
*   `neovim/lua/plugins/example.lua` -> `neovim_custom/lua/plugins/example.lua`

## File Permissions

Important file permissions:
*   `scripts/unified_dotfiles_manager.sh`: Executable (755)
*   All configuration files: Readable (644)

## Git Submodules

This repository uses Git submodules for:
*   `neovim/`: LazyVim configuration
*   `zsh/plugins/zsh-syntax-highlighting`: Syntax highlighting plugin
*   `zsh/plugins/zsh-autosuggestions`: Autosuggestions plugin
*   `zsh/plugins/zsh-history-substring-search`: History search plugin

To update submodules: `git submodule update --remote --merge`

## Recent Improvements

1. Merged all scripts into a single unified script with command-line options
2. Replaced Powerlevel10k with Oh My Posh
3. Enhanced tmux auto-start to work for all terminal sessions
4. Simplified script management by keeping only one main script

## Common Maintenance Tasks

For bots performing maintenance:

1. Update submodules: `git submodule update --remote --merge`
2. Test configuration: `./scripts/unified_dotfiles_manager.sh --test-config`
3. Update BOTS.md when versions change
4. Verify symlinks: Check that all symlinks in the Symlink Structure section exist and point to correct locations

## Updating BOTS.md

Update this file when:
*   Adding new configurations or tools
*   Changing directory structure
*   Updating application versions
*   Modifying Oh My Posh configurations