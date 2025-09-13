#!/bin/bash
# Unified dotfiles management script
# This script can install tools, apply configurations, or both

# Exit on any error
set -e

# Default options
INSTALL_TOOLS=false
APPLY_CONFIGS=false
TEST_CONFIG=false
SET_ZSH_DEFAULT=false
HELP=false

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log() {
    echo -e "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

log_info() {
    log "${BLUE}INFO${NC}: $1"
}

log_success() {
    log "${GREEN}SUCCESS${NC}: $1"
}

log_warning() {
    log "${YELLOW}WARNING${NC}: $1"
}

log_error() {
    log "${RED}ERROR${NC}: $1" >&2
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
    echo "  -i, --install-tools    Install the latest versions of tools (nvim, ranger, tmux, zsh, lazygit, k9s)"
    echo "  -c, --apply-configs    Apply dotfiles configurations (create symlinks)"
    echo "  -t, --test-config      Test ZSH configuration"
    echo "  -a, --all              Install tools and apply configurations"
    echo "  -z, --set-zsh-default  Set zsh as the default shell"
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

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to compare version strings
version_gt() {
    test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1"
}

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

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
        mkdir -p "$target_dir"
    fi
    
    # Check if target is already a symlink pointing to the correct source
    if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
        log_info "Symlink already exists and is correct: $target -> $source"
        return 0
    fi
    
    # Create symlink
    if ln -sf "$source" "$target"; then
        log_success "Created symlink: $target -> $source"
        return 0
    else
        log_error "Failed to create symlink $target -> $source"
        return 1
    fi
}

# Function to install tools
install_tools() {
    log_info "=== Installing latest tools ==="
    
    # Check if we're on Ubuntu
    if ! grep -q "Ubuntu" /etc/os-release 2>/dev/null; then
        log_warning "This script is designed for Ubuntu systems."
        read -p "Continue anyway? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi

    # Install dependencies with error handling
    log_info "Updating package lists..."
    if ! sudo apt update; then
        log_error "Failed to update package lists"
        exit 1
    fi

    log_info "Installing dependencies..."
    if ! sudo apt install -y software-properties-common build-essential wget curl git \
        libevent-dev libncurses-dev automake pkg-config bison libbz2-dev \
        libreadline-dev libsqlite3-dev libssl-dev libffi-dev zlib1g-dev \
        liblzma-dev llvm libncursesw5-dev xz-utils tk-dev libxml2-dev \
        libxmlsec1-dev libffi-dev liblzma-dev python3-dev python3-pip; then
        log_error "Failed to install dependencies"
        exit 1
    fi

    # Install latest zsh
    log_info "Installing latest zsh..."
    # Always install the latest version available via apt
    sudo apt install -y zsh
    if command_exists zsh; then
        ZSH_VERSION=$(zsh --version | cut -d' ' -f2)
        log_success "zsh $ZSH_VERSION installed"
    fi

    # Install latest ranger
    log_info "Installing latest ranger..."
    # Try to install via apt first, then fallback to pip
    if ! sudo apt install -y ranger; then
        log_warning "Failed to install ranger via apt, trying pip..."
        # Always install the latest version available via pip
        if ! pip3 install ranger-fm --upgrade --break-system-packages 2>/dev/null; then
            # Try without break-system-packages flag
            pip3 install ranger-fm --upgrade 2>/dev/null || true
        fi
    fi
    if command_exists ranger; then
        RANGER_VERSION=$(ranger --version 2>&1 | head -n 1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
        log_success "ranger $RANGER_VERSION installed"
    fi

    # Install latest tmux
    log_info "Installing latest tmux..."
    # Try to install via apt first
    if ! sudo apt install -y tmux; then
        log_error "Failed to install tmux"
        exit 1
    fi
    if command_exists tmux; then
        TMUX_VERSION=$(tmux -V | cut -d' ' -f2)
        log_success "tmux $TMUX_VERSION installed"
    fi

    # Install latest stable Neovim
    log_info "Installing latest stable Neovim..."
    # Always install the latest stable version by compiling from source

    # Install build dependencies for Neovim
    log_info "Installing build dependencies for Neovim..."
    if ! sudo apt install -y ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip git; then
        log_error "Failed to install build dependencies for Neovim"
        exit 1
    fi

    # Clone the Neovim repository
    log_info "Cloning Neovim repository..."
    cd /tmp
    if [ -d "neovim" ]; then
        rm -rf neovim
    fi
    git clone https://github.com/neovim/neovim.git
    cd neovim

    # Get the latest stable release tag
    log_info "Finding latest stable release..."
    LATEST_TAG=$(git tag -l --sort=-v:refname | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | head -n 1)
    if [ -z "$LATEST_TAG" ]; then
        log_error "Failed to find latest stable release tag"
        exit 1
    fi

    log_info "Checking out latest stable release: $LATEST_TAG"
    git checkout "$LATEST_TAG"

    # Build and install Neovim
    log_info "Building Neovim..."
    make CMAKE_BUILD_TYPE=Release
    log_info "Installing Neovim..."
    sudo make install

    # Clean up
    cd ..
    rm -rf neovim

    if command_exists nvim; then
        NVIM_VERSION=$(nvim --version | head -n 1)
        log_success "Neovim $NVIM_VERSION installed"
    fi

    # Install lazygit (latest stable release)
    log_info "Installing lazygit..."
    # Always install the latest version of lazygit
    cd /tmp
    LAZYGIT_URL=$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep browser_download_url | grep Linux_x86_64 | head -n 1 | cut -d '"' -f 4)
    if [ -z "$LAZYGIT_URL" ]; then
        log_warning "Failed to find lazygit download URL, trying alternative method..."
        # Alternative method using the GitHub releases page directly
        LAZYGIT_VERSION=$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')
        if [ -z "$LAZYGIT_VERSION" ]; then
            log_error "Failed to determine lazygit version"
            exit 1
        fi
        LAZYGIT_URL="https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    fi

    log_info "Downloading lazygit from: $LAZYGIT_URL"
    if ! wget "$LAZYGIT_URL" -O lazygit.tar.gz; then
        log_error "Failed to download lazygit"
        exit 1
    fi

    tar xzf lazygit.tar.gz
    sudo install lazygit /usr/local/bin
    rm lazygit.tar.gz lazygit

    # Check installed version
    if command_exists lazygit; then
        LAZYGIT_VERSION=$(lazygit --version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
        log_success "lazygit $LAZYGIT_VERSION installed"
    else
        log_success "lazygit installed"
    fi

    # Install k9s (latest stable release)
    log_info "Installing k9s..."
    # Always install the latest version of k9s
    cd /tmp
    K9S_URL=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | grep browser_download_url | grep Linux_amd64 | head -n 1 | cut -d '"' -f 4)
    if [ -z "$K9S_URL" ]; then
        log_warning "Failed to find k9s download URL, trying alternative method..."
        # Alternative method using the GitHub releases page directly
        K9S_VERSION=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')
        if [ -z "$K9S_VERSION" ]; then
            log_error "Failed to determine k9s version"
            exit 1
        fi
        K9S_URL="https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/k9s_Linux_amd64.tar.gz"
    fi

    log_info "Downloading k9s from: $K9S_URL"
    if ! wget "$K9S_URL" -O k9s.tar.gz; then
        log_error "Failed to download k9s"
        exit 1
    fi

    tar xzf k9s.tar.gz k9s
    sudo install k9s /usr/local/bin
    rm k9s.tar.gz k9s

    # Install Oh My Posh
    log_info "Installing Oh My Posh..."
    
    # Ensure the target directory exists
    OMP_DIR="$HOME/.local/bin"
    if [ ! -d "$OMP_DIR" ]; then
        log_info "Creating directory: $OMP_DIR"
        mkdir -p "$OMP_DIR"
    fi
    
    # Download and install Oh My Posh
    if curl -s https://ohmyposh.dev/install.sh | bash -s -- -d "$OMP_DIR"; then
        log_success "Oh My Posh installed successfully"
    else
        log_warning "Failed to install Oh My Posh"
    fi

    # Check installed version
    if command_exists "$OMP_DIR/oh-my-posh"; then
        OMP_VERSION=$("$OMP_DIR/oh-my-posh" --version)
        log_success "Oh My Posh $OMP_VERSION installed"
    fi

    # Check installed version
    if command_exists k9s; then
        K9S_VERSION_OUTPUT=$(k9s version 2>&1)
        K9S_VERSION=$(echo "$K9S_VERSION_OUTPUT" | grep Version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "")
        if [ -z "$K9S_VERSION" ]; then
            # Try alternative format
            K9S_VERSION=$(echo "$K9S_VERSION_OUTPUT" | head -n 1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
        fi
        log_success "k9s $K9S_VERSION installed"
    else
        log_success "k9s installed"
    fi

    # Verify installations
    log_info "Verifying installations..."
    log_info "ZSH version: $(zsh --version)"
    log_info "Ranger version: ranger $(ranger --version 2>&1 | head -n 1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
    log_info "Tmux version: $(tmux -V)"
    log_info "Neovim version: $(nvim --version | head -n 1)"
    if command_exists lazygit; then
        log_info "Lazygit version: $(lazygit --version 2>&1)"
    else
        log_warning "Lazygit: Not installed"
    fi
    if command_exists k9s; then
        log_info "K9s version: $(k9s version 2>&1 | grep Version)"
    else
        log_warning "K9s: Not installed"
    fi
    if command_exists ~/.local/bin/oh-my-posh; then
        log_info "Oh My Posh version: $($HOME/.local/bin/oh-my-posh --version)"
    else
        log_warning "Oh My Posh: Not installed"
    fi

    log_success "All tools have been updated to their latest versions!"
}

# Function to apply configurations
apply_configs() {
    log_info "=== Applying dotfiles configurations ==="
    
    # Initialize and update submodules
    log_info "Initializing and updating submodules..."
    cd "$DOTFILES_DIR"
    if ! git submodule update --init --recursive; then
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

    log_success "Dotfiles have been linked successfully!"
}

# Function to test ZSH configuration
test_config() {
    log_info "Testing ZSH configuration..."

    # Test 1: Check if zsh is installed
    if ! command -v zsh &> /dev/null; then
        log_error "zsh is not installed"
        exit 1
    fi
    log_success "zsh is installed ($(zsh --version))"

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
# Function to set zsh as default shell
set_zsh_default() {
    log_info "=== Setting zsh as default shell ==="
    read -p "Do you want to set zsh as your default shell? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if chsh -s /usr/bin/zsh; then
            log_success "zsh has been set as your default shell. Log out and back in to apply changes."
        else
            log_error "Failed to set zsh as default shell. This may be because you need to enter your password for the chsh command."
            log_info "Try running 'chsh -s /usr/bin/zsh' manually and enter your password when prompted."
        fi
    fi
}

# Main execution
main() {
    # Execute requested actions
    if [[ "$INSTALL_TOOLS" == true ]]; then
        install_tools
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

    log_success "=== Dotfiles management complete ==="
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