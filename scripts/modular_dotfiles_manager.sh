#!/bin/bash
# Modular dotfiles management script
# This script can install tools, apply configurations, or both

# Exit on any error
set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source all modules
if [ -f "$SCRIPT_DIR/utils.sh" ]; then
    source "$SCRIPT_DIR/utils.sh"
else
    echo "Error: utils.sh not found at $SCRIPT_DIR/utils.sh!" >&2
    exit 1
fi

if [ -f "$SCRIPT_DIR/install_tools.sh" ]; then
    source "$SCRIPT_DIR/install_tools.sh"
else
    echo "Error: install_tools.sh not found!" >&2
    exit 1
fi

if [ -f "$SCRIPT_DIR/apply_configs.sh" ]; then
    source "$SCRIPT_DIR/apply_configs.sh"
else
    echo "Error: apply_configs.sh not found!" >&2
    exit 1
fi

if [ -f "$SCRIPT_DIR/test_config.sh" ]; then
    source "$SCRIPT_DIR/test_config.sh"
else
    echo "Error: test_config.sh not found!" >&2
    exit 1
fi

if [ -f "$SCRIPT_DIR/set_zsh_default.sh" ]; then
    source "$SCRIPT_DIR/set_zsh_default.sh"
else
    echo "Error: set_zsh_default.sh not found!" >&2
    exit 1
fi

# Default options
INSTALL_TOOLS=false
APPLY_CONFIGS=false
TEST_CONFIG=false
SET_ZSH_DEFAULT=false
HELP=false
FORCE_REINSTALL=false

# Validate directories by setting SCRIPT_DIR and DOTFILES_DIR directly
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
export SCRIPT_DIR="$SCRIPT_DIR"
export DOTFILES_DIR="$DOTFILES_DIR"

# Verify directories exist
if [ ! -d "$SCRIPT_DIR" ]; then
    log_error "Script directory does not exist: $SCRIPT_DIR"
    exit 1
fi

if [ ! -d "$DOTFILES_DIR" ]; then
    log_error "Dotfiles directory does not exist: $DOTFILES_DIR"
    exit 1
fi

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -i|--install-tools)
            INSTALL_TOOLS=true
            shift
            ;;
        -c|--apply-configs)
            APPLY_CONFIGS=true
            shift
            ;;
        -t|--test-config)
            TEST_CONFIG=true
            shift
            ;;
        -a|--all)
            INSTALL_TOOLS=true
            APPLY_CONFIGS=true
            shift
            ;;
        -z|--set-zsh-default)
            SET_ZSH_DEFAULT=true
            shift
            ;;
        -f|--force-reinstall)
            FORCE_REINSTALL=true
            shift
            ;;
        -h|--help)
            HELP=true
            shift
            ;;
        *)
            log_error "Unknown option: $1"
            HELP=true
            shift
            ;;
    esac
done

# Show help if requested or no options provided
if [[ "$HELP" == true ]] || [[ "$INSTALL_TOOLS" == false && "$APPLY_CONFIGS" == false && "$TEST_CONFIG" == false && "$SET_ZSH_DEFAULT" == false ]]; then
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -i, --install-tools    Install the latest versions of tools (nvim, ranger, tmux, zsh, lazygit, k9s, sway, mako, swaylock, clipse)"
    echo "  -c, --apply-configs    Apply dotfiles configurations (create symlinks)"
    echo "  -t, --test-config      Test ZSH configuration"
    echo "  -a, --all              Install tools and apply configurations"
    echo "  -z, --set-zsh-default  Set zsh as the default shell"
    echo "  -f, --force-reinstall  Force reinstall tools even if already installed"
    echo "  -h, --help             Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 -i                  Install tools only"
    echo "  $0 -c                  Apply configurations only"
    echo "  $0 -t                  Test ZSH configuration"
    echo "  $0 -a                  Install tools and apply configurations"
    echo "  $0 -z                  Set zsh as the default shell"
    echo "  $0 -a -z               Install tools, apply configurations, and set zsh as default shell"
    exit 0
fi

# Main execution
main() {
    # Execute requested actions
    if [[ "$INSTALL_TOOLS" == true ]]; then
        install_tools "$FORCE_REINSTALL"
    fi

    if [[ "$APPLY_CONFIGS" == true ]]; then
        apply_configs
    fi

    if [[ "$TEST_CONFIG" == true ]]; then
        test_config
    fi

    # Set zsh as default shell if requested
    if [[ "$SET_ZSH_DEFAULT" == true ]]; then
        set_zsh_default
    fi
    
    # Set neovim as default editor
    show_progress "Setting neovim as default editor..."
    if command -v nvim >/dev/null 2>&1; then
        # Set nvim as the default editor for the system
        if [ -w "/etc/environment" ]; then
            if ! grep -q "EDITOR=nvim" /etc/environment 2>/dev/null; then
                echo 'EDITOR=nvim' | sudo tee -a /etc/environment > /dev/null
            fi
            if ! grep -q "VISUAL=nvim" /etc/environment 2>/dev/null; then
                echo 'VISUAL=nvim' | sudo tee -a /etc/environment > /dev/null
            fi
        else
            # Fallback: add to user's shell config
            if ! grep -q "export EDITOR=nvim" ~/.zshrc 2>/dev/null && [ -w ~/.zshrc ]; then
                echo 'export EDITOR=nvim' >> ~/.zshrc
                echo 'export VISUAL=nvim' >> ~/.zshrc
            fi
        fi
        
        # Update alternatives system-wide if possible
        if command -v update-alternatives >/dev/null 2>&1; then
            if [ -x "/usr/local/bin/nvim" ]; then
                sudo update-alternatives --install /usr/bin/editor editor /usr/local/bin/nvim 100
                sudo update-alternatives --install /usr/bin/vi vi /usr/local/bin/nvim 100
            elif [ -x "/usr/bin/nvim" ]; then
                sudo update-alternatives --install /usr/bin/editor editor /usr/bin/nvim 100
                sudo update-alternatives --install /usr/bin/vi vi /usr/bin/nvim 100
            fi
        fi
        
        log_success "Neovim set as default editor"
    else
        log_warning "Neovim not found, cannot set as default editor"
    fi

    show_progress "Dotfiles management complete"
    if [[ "$INSTALL_TOOLS" == true ]] && [[ "$APPLY_CONFIGS" == true ]]; then
        log_info "All tools installed and configurations applied."
    elif [[ "$INSTALL_TOOLS" == true ]]; then
        log_info "Tools installation complete."
    elif [[ "$APPLY_CONFIGS" == true ]]; then
        log_info "Configurations applied."
    elif [[ "$TEST_CONFIG" == true ]]; then
        log_info "Configuration test completed."
    elif [[ "$SET_ZSH_DEFAULT" == true ]]; then
        log_info "Default shell setting process completed."
    fi
}

# Run main function
main "$@"