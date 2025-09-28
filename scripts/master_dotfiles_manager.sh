#!/bin/bash
# Master dotfiles management script
# This script discovers and runs individual install scripts based on command-line options

# Exit on any error
set -e

# Default options
INSTALL_TOOLS=false
APPLY_CONFIGS=false
TEST_CONFIG=false
SET_ZSH_DEFAULT=false
HELP=false
FORCE_REINSTALL=false
SPECIFIC_TOOL=""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Silent and debug mode flags
SILENT_MODE=true
DEBUG_MODE=false

# Source common utilities early so all functions have access
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UTILS_DIR="$SCRIPT_DIR/utils.sh"

if [ -f "$UTILS_DIR" ]; then
    source "$UTILS_DIR"
else
    echo "ERROR: utils.sh not found at $UTILS_DIR"
    exit 1
fi

# Progress tracking
show_progress() {
    if [ "$SILENT_MODE" = true ]; then
        echo -e "${BLUE}>>> $1${NC}" >&2
    fi
}

# Logging functions
log() {
    # Only log errors in silent mode, otherwise show all messages
    if [ "$SILENT_MODE" = false ]; then
        echo -e "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
    fi
}

log_info() {
    # Only log errors in silent mode
    if [ "$SILENT_MODE" = false ]; then
        log "${BLUE}INFO${NC}: $1"
    fi
}

log_success() {
    # Only log errors in silent mode
    if [ "$SILENT_MODE" = false ]; then
        log "${GREEN}SUCCESS${NC}: $1"
    fi
}

log_warning() {
    # Only log errors in silent mode
    if [ "$SILENT_MODE" = false ]; then
        log "${YELLOW}WARNING${NC}: $1"
    fi
}

log_error() {
    # Always print errors
    echo -e "[$(date +'%Y-%m-%d %H:%M:%S')] ${RED}ERROR${NC}: $1" >&2
}

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
        --tool)
            SPECIFIC_TOOL="$2"
            INSTALL_TOOLS=true
            shift 2
            ;;
        --debug)
            DEBUG_MODE=true
            SILENT_MODE=false  # Enable output when debugging
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
    echo "  --tool TOOL_NAME       Install a specific tool by name (e.g., zsh, neovim, ranger, etc.)"
    echo "  --debug                Enable debug mode with verbose output"
    echo "  -h, --help             Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 -i                  Install tools only"
    echo "  $0 -c                  Apply configurations only"
    echo "  $0 -t                  Test ZSH configuration"
    echo "  $0 -a                  Install tools and apply configurations"
    echo "  $0 -z                  Set zsh as the default shell"
    echo "  $0 -a -z               Install tools, apply configurations, and set zsh as default shell"
    echo "  $0 --tool zsh          Install only zsh"
    echo "  $0 --tool neovim       Install only neovim"
    echo "  $0 --debug --tool zsh  Install only zsh with debug output"
    exit 0
fi

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# Function to discover available tools
discover_tools() {
    local install_dir="$SCRIPT_DIR/install"
    if [ -d "$install_dir" ]; then
        for dir in "$install_dir"/*/; do
            if [ -d "$dir" ] && [ -f "$dir/install.sh" ]; then
                basename "$dir"
            fi
        done
    fi
}

# Function to run a specific tool's install script
run_tool_install() {
    local tool_name="$1"
    local tool_dir="$SCRIPT_DIR/install/$tool_name"
    
    if [ -d "$tool_dir" ] && [ -f "$tool_dir/install.sh" ]; then
        if [ "$DEBUG_MODE" = true ]; then
        log_info "Installing $tool_name..."
        debug_log "Running install script: $tool_dir/install.sh with DEBUG_MODE=$DEBUG_MODE"
        env DEBUG_MODE=true "$tool_dir/install.sh"
    else
        "$tool_dir/install.sh"
    fi
    else
        log_error "Install script not found for $tool_name at $tool_dir/install.sh"
        exit 1
    fi
}

# Function to run all tools' install scripts
run_all_tool_installs() {
    local install_dir="$SCRIPT_DIR/install"
    local available_tools=($(discover_tools))
    
    show_progress "Available tools: ${available_tools[*]}"
    
    for tool in "${available_tools[@]}"; do
        if [ "$tool" != "utils" ]; then  # Skip the utils directory
            log_info "Installing $tool..."
            run_tool_install "$tool"
        fi
    done
}

# Function to create symlink with validation
create_symlink() {
    local source="$1"
    local target="$2"
    
    # Check if source file exists
    if [ ! -f "$source" ] && [ ! -d "$source" ]; then
        log_warning "Source $source does not exist"
        return 1
    fi
    
    # Create target directory if it doesn't exist
    local target_dir=$(dirname "$target")
    if [ ! -d "$target_dir" ]; then
        mkdir -p "$target_dir" > /dev/null 2>&1
    fi
    
    # Check if target is already a symlink pointing to the correct source
    if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
        log_info "Symlink already exists and is correct: $target -> $source"
        return 0
    fi
    
    # Create symlink
    if ln -sf "$source" "$target" > /dev/null 2>&1; then
        log_success "Created symlink: $target -> $source"
        return 0
    else
        log_error "Failed to create symlink $target -> $source"
        return 1
    fi
}

# Function to apply configurations
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
    create_symlink "$DOTFILES_DIR/sway/clipboard_monitor.sh" "$HOME/.config/sway/clipboard_monitor.sh"
    create_symlink "$DOTFILES_DIR/waybar" "$HOME/.config/waybar"

    show_progress "Dotfiles have been linked successfully!"
}

# Function to test ZSH configuration
test_config() {
    log_info "Testing ZSH configuration..."

    # Source utils
    if [ -f "$SCRIPT_DIR/utils.sh" ]; then
        source "$SCRIPT_DIR/utils.sh"
    else
        log_error "utils.sh not found at $SCRIPT_DIR/utils.sh"
        exit 1
    fi

    # Test 1: Check if zsh is installed
    if ! command -v zsh &> /dev/null; then
        log_error "zsh is not installed"
        exit 1
    fi
    log_success "zsh is installed ($(zsh --version 2>/dev/null))"

    # Test 2: Check if .zshrc file exists
    if [ ! -f ~/.zshrc ]; then
        log_error "~/.zshrc does not exist"
        exit 1
    fi
    log_success "~/.zshrc exists"

    # Test 3: Check if required files exist
    required_files=(
        "$DOTFILES_DIR/zsh/oh-my-posh-config.json"
        "$DOTFILES_DIR/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
        "$DOTFILES_DIR/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
        "$DOTFILES_DIR/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh"
    )

    all_files_exist=true
    for file in "${required_files[@]}"; do
        if [ ! -f "$file" ]; then
            log_error "Required file $file does not exist"
            all_files_exist=false
        fi
    done

    if [ "$all_files_exist" = true ]; then
        log_success "All required configuration files exist"
    else
        log_error "Some required files are missing. Run with --apply-configs to fix."
        exit 1
    fi

    # Test 4: Check if submodules are properly initialized
    log_info "Checking submodule status..."
    cd "$DOTFILES_DIR"
    submodule_status=$(git submodule status 2>&1)
    if echo "$submodule_status" | grep -q "^-"; then
        log_warning "Some submodules are not initialized"
        echo "$submodule_status" | grep "^-" | while read line; do
            log_warning "Uninitialized submodule: $(echo "$line" | cut -d' ' -f2)"
        done
    else
        log_success "All submodules are properly initialized"
    fi

    # Test 5: Check if zsh can source .zshrc without critical errors
    log_info "Testing zsh configuration load..."
    zsh_output=$(timeout 10s zsh -i -c "echo 'ZSH loaded successfully'" 2>&1)
    if [ $? -eq 124 ]; then
        log_warning "ZSH configuration test timed out (may be due to tmux auto-start)"
    elif echo "$zsh_output" | grep -q "ZSH loaded successfully"; then
        log_success ".zshrc loads without critical errors"
    else
        log_warning "Potential issues when loading .zshrc:"
        echo "$zsh_output" | head -5
    fi

    log_success "ZSH configuration test completed."
}

# Function to set zsh as default shell
set_zsh_default() {
    show_progress "Setting zsh as default shell"
    # Check if we're running interactively
    if [ -t 0 ]; then
        read -p "Do you want instructions to set zsh as your default shell? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            log_info "To set zsh as your default shell, run the following command:"
            echo "    chsh -s /usr/bin/zsh" >&2
            log_info "You will be prompted to enter your password."
            log_info "After running this command, log out and back in for the changes to take effect."
        fi
    else
        # Non-interactive mode - just provide the instructions
        log_info "To set zsh as your default shell, run the following command:"
        echo "    chsh -s /usr/bin/zsh" >&2
        log_info "You will be prompted to enter your password."
        log_info "After running this command, log out and back in for the changes to take effect."
    fi
}

# Main execution
main() {
    # Execute requested actions
    if [[ "$INSTALL_TOOLS" == true ]]; then
        if [ -n "$SPECIFIC_TOOL" ]; then
            # Install specific tool
            available_tools=($(discover_tools))
            tool_found=false
            
            for tool in "${available_tools[@]}"; do
                if [ "$tool" = "$SPECIFIC_TOOL" ]; then
                    tool_found=true
                    break
                fi
            done
            
            if [ "$tool_found" = true ]; then
                run_tool_install "$SPECIFIC_TOOL"
            else
                log_error "Tool '$SPECIFIC_TOOL' not found. Available tools: ${available_tools[*]}"
                exit 1
            fi
        else
            # Install all tools
            run_all_tool_installs
        fi
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