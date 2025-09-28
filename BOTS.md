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
*   `sway/`: Contains the Sway configuration files.
    *   `config`: Main Sway configuration file with window management settings, keybindings, and appearance settings
*   `wofi/`: Contains the `wofi` configuration files for the application launcher.
    *   `config`: Configuration file for wofi, a simple wayland-native application launcher
    *   `style.css`: CSS styling for the wofi appearance
*   `sway/`: Contains the Sway configuration files.
    *   `config`: Main Sway configuration file with window management settings, keybindings, and appearance settings - now uses wofi as the application launcher
*   `scripts/`: Contains scripts for managing the dotfiles.
    *   `master_dotfiles_manager.sh`: Main entry point that auto-discovers and runs individual install scripts, with comprehensive debug capabilities
    *   `utils.sh`: Common utility functions and debug logging used by all install scripts
    *   `install/`: Directory containing individual install scripts for each application
        *   `zsh/`: Install script for Zsh and Oh My Posh (with enhanced logic to check for existing installation)
        *   `neovim/`: Install script for Neovim and its dependencies
        *   `ranger/`: Install script for Ranger file manager
        *   `tmux/`: Install script for Tmux
        *   `sway/`: Install script for Sway and related packages
        *   `lazygit/`: Install script for Lazygit
        *   `k9s/`: Install script for K9s
        *   `clipse/`: Install script for Clipse

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
2. Run the master script with desired options:
   * Install tools only: `./scripts/master_dotfiles_manager.sh --install-tools`
   * Install specific tool: `./scripts/master_dotfiles_manager.sh --tool zsh`
   * Apply configurations only: `./scripts/master_dotfiles_manager.sh --apply-configs`
   * Test configuration: `./scripts/master_dotfiles_manager.sh --test-config`
   * Install tools and apply configurations: `./scripts/master_dotfiles_manager.sh --all`
   * Also set zsh as default shell: `./scripts/master_dotfiles_manager.sh --all --set-zsh-default`

## Application Versions Tracking

This repository installs the latest stable versions of key applications using the `scripts/master_dotfiles_manager.sh` script. The currently installed versions are tracked here for reference:

*   **Neovim**: v0.11.4 (stable version)
*   **Zsh**: v5.8
*   **Ranger**: v1.9.4
*   **Tmux**: v3.5a
*   **Lazygit**: v0.55.0
*   **K9s**: v0.50.13
*   **Oh My Posh**: v26.23.3
*   **Sway**: Latest from Ubuntu 25.04 repository (sway package)
*   **Mako**: Latest from Ubuntu 25.04 repository (mako-notifier package)
*   **Nerd Fonts**: JetBrainsMono Nerd Font for proper icon display in Waybar

Note: The script now installs the latest stable versions of all tools rather than locking to specific versions. These tracked versions are for reference purposes only.

For the submodules (plugins), specific commits are locked via Git submodules to ensure consistent behavior.

## Master Dotfiles Manager Script

This is the main script that auto-discovers and executes individual install scripts. It provides:

### Usage
```bash
./scripts/master_dotfiles_manager.sh [OPTIONS]

Options:
  -i, --install-tools    Install the latest versions of tools (nvim, ranger, tmux, zsh, lazygit, k9s, sway, mako, swaylock, clipse)
  -c, --apply-configs    Apply dotfiles configurations (create symlinks)
  -t, --test-config      Test ZSH configuration
  -a, --all              Install tools and apply configurations
  -z, --set-zsh-default  Set zsh as the default shell
  -f, --force-reinstall  Force reinstall tools even if already installed
  --tool TOOL_NAME       Install a specific tool by name (e.g., zsh, neovim, ranger, etc.)
  --debug                Enable debug mode with verbose output
  -h, --help             Show this help message
```

### Key Functions
*   `discover_tools()`: Discovers available tools in the install directory
*   `run_tool_install()`: Runs a specific tool's install script
*   `run_all_tool_installs()`: Runs all available tool install scripts
*   `apply_configs()`: Creates symlinks for all dotfiles
*   `test_config()`: Tests ZSH configuration
*   `create_symlink()`: Creates validated symlinks
*   `set_zsh_default()`: Sets zsh as default shell (requires password authentication)

### Debug Mode
The script includes comprehensive debug capabilities:
*   `--debug` flag enables verbose output showing detailed execution steps
*   Individual install scripts also support `DEBUG_MODE` environment variable
*   All scripts include `debug_log()` function for detailed tracing
*   Debug output includes OS detection, installation checks, and process flow
*   Each script intelligently checks if tools are already installed before attempting installation

### Environment Variables
*   `SCRIPT_DIR`: Directory where the script is located
*   `DOTFILES_DIR`: Root directory of the dotfiles repository

### Setting Zsh as Default Shell

To enable the tmux auto-start feature, zsh must be set as the default shell since the tmux auto-start logic is in the `.zshrc` file.

Run: `./scripts/master_dotfiles_manager.sh --set-zsh-default`

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
1. Run: `./scripts/master_dotfiles_manager.sh --set-zsh-default`
2. Log out and log back in for the changes to take effect

## Symlink Structure

The master script creates the following symlinks:
*   `~/.zshrc` -> `zsh/.zshrc`
*   `~/.config/ranger/rc.conf` -> `ranger/rc.conf`
*   `~/.tmux.conf` -> `tmux/.tmux.conf`
*   `~/.config/nvim` -> `neovim/`
*   `~/.config/sway/config` -> `sway/config`
*   `~/.config/waybar` -> `waybar/`
*   `neovim/lua/config/custom.lua` -> `neovim_custom/lua/config/custom.lua`
*   `neovim/lua/plugins/example.lua` -> `neovim_custom/lua/plugins/example.lua`

Note: For wallpapers, users should manually copy their wallpaper images to `~/Pictures/Wallpapers/` or create a symlink from `~/Pictures/Wallpapers` to `dot_files/wallpapers/`

## File Permissions

Important file permissions:
*   `scripts/master_dotfiles_manager.sh`: Executable (755)
*   All individual install scripts: Executable (755)
*   All configuration files: Readable (644)

## Sway Configuration

Sway is configured as a Wayland compositor with the following components:
*   Main configuration: `sway/config` with window management, keybindings, and appearance settings
*   Waybar configuration: `sway/waybar/config` and `sway/waybar/style.css` for the status bar

Key features:
*   Custom keybindings using SUPER as the main modifier
*   Workspace management with keyboard shortcuts
*   Screen capture and media controls
*   Integration with common applications like foot, wmenu, thunar
*   Waybar status bar for system information and controls
*   Swaylock for screen locking (keybinding: Mod+Shift+grave)

## Swaylock Configuration

Swaylock is configured with:
*   Configuration file: `swaylock/config` with Nord theme colors
*   Keybinding: `$mod+Shift+grave` to lock the screen
*   Features: clock display, failed attempts counter, themed colors
*   Background: Uses current desktop background from `wallpapers/` directory

## Wallpapers

Wallpaper images are stored in:
*   Directory: `wallpapers/`
*   Currently configured wallpaper: `wallpaper.png`
*   Used by: Sway background and Swaylock

## Git Submodules

This repository uses Git submodules for:
*   `neovim/`: LazyVim configuration
*   `zsh/plugins/zsh-syntax-highlighting`: Syntax highlighting plugin
*   `zsh/plugins/zsh-autosuggestions`: Autosuggestions plugin
*   `zsh/plugins/zsh-history-substring-search`: History search plugin

To update submodules: `git submodule update --remote --merge`

## Recent Improvement

1. Split the monolithic unified script into individual install scripts for each application, with a master script that auto-discovers and runs them
2. Replaced Powerlevel10k with Oh My Posh
3. Enhanced tmux auto-start to work for all terminal sessions
4. Improved modularity by allowing installation of individual tools
5. Added comprehensive debug capabilities with `--debug` option
6. Enhanced individual scripts with intelligent checks for already-installed tools
7. Improved logging and error reporting across all scripts

10. Added utility script for manual Wayland clipboard management if needed

## Common Maintenance Tasks

For bots performing maintenance:

1. Update submodules: `git submodule update --remote --merge`
2. Test configuration: `./scripts/master_dotfiles_manager.sh --test-config`
3. Update BOTS.md when versions change
4. Verify symlinks: Check that all symlinks in the Symlink Structure section exist and point to correct locations
5. Add new tools by creating a new directory in `scripts/install/` with an `install.sh` script
6. Debug issues using: `./scripts/master_dotfiles_manager.sh --debug --tool <tool_name>`
7. Run individual scripts with debug: `DEBUG_MODE=true ./install/<tool>/install.sh`

## Debugging and Troubleshooting

The modular script system includes comprehensive debugging capabilities:

### Running with Debug Output
```bash
# Debug a specific tool installation
./scripts/master_dotfiles_manager.sh --debug --tool zsh

# Debug configuration application
./scripts/master_dotfiles_manager.sh --debug --apply-configs

# Run individual script with debug
DEBUG_MODE=true ./scripts/install/zsh/install.sh
DEBUG_MODE=true ./scripts/install/neovim/install.sh
```

### Enhanced Features
* Each script intelligently checks if tools are already installed before attempting installation
* Detailed logging shows OS detection, installation steps, and process flow
* Error messages include specific information for troubleshooting
* Master script provides clear information about which individual script is being executed

### Wayland Clipboard Issue (Clipse)

If you're experiencing issues with clipse not properly setting the clipboard in Wayland (Sway), try the following:

1. Ensure wl-clipboard utilities are installed:
   ```bash
   sudo apt install wl-clipboard
   ```

2. The issue may be related to Wayland's security model. Make sure clipse is properly integrated by using the keyboard shortcut:
   - Press `Mod+Shift+V` to open clipse
   - Use the interface to select clipboard history
   - When selecting an entry, it should set it to the current clipboard

## Updating BOTS.md

Update this file when:
*   Adding new configurations or tools
*   Changing directory structure
*   Updating application versions
*   Modifying Oh My Posh configurations