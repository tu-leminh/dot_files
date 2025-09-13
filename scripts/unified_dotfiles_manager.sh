#!/bin/bash
# Unified dotfiles management script
# This script can install tools, apply configurations, or both

# Default options
INSTALL_TOOLS=false
APPLY_CONFIGS=false
TEST_CONFIG=false
SET_ZSH_DEFAULT=false
HELP=false

# Logging function
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
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
            echo "Unknown option: $1"
            HELP=true
            shift
            ;;
    esac
done

# Show help if requested or no options provided
if [[ "$HELP" == true ]] || [[ "$INSTALL_TOOLS" == false && "$APPLY_CONFIGS" == false && "$TEST_CONFIG" == false ]]; then
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -i, --install-tools    Install the latest versions of tools (nvim, ranger, tmux, zsh, lazygit, k9s)"
    echo "  -c, --apply-configs    Apply dotfiles configurations (create symlinks)"
    echo "  -t, --test-config      Test ZSH configuration"
    echo "  -a, --all              Install tools and apply configurations"
    echo "  -z, --set-zsh-default  Set zsh as the default shell (only works with -i or -a)"
    echo "  -h, --help             Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 -i                  Install tools only"
    echo "  $0 -c                  Apply configurations only"
    echo "  $0 -t                  Test ZSH configuration"
    echo "  $0 -a                  Install tools and apply configurations"
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
        log "Warning: Source $source does not exist"
        return 1
    fi
    
    # Create target directory if it doesn't exist
    local target_dir=$(dirname "$target")
    if [ ! -d "$target_dir" ]; then
        mkdir -p "$target_dir"
    fi
    
    # Create symlink
    if ln -sf "$source" "$target"; then
        log "Created symlink: $target -> $source"
        return 0
    else
        log "Error: Failed to create symlink $target -> $source"
        return 1
    fi
}

# Function to install tools
install_tools() {
    log "=== Installing latest tools ==="
    
    # Check if we're on Ubuntu
    if ! grep -q "Ubuntu" /etc/os-release 2>/dev/null; then
        log "Warning: This script is designed for Ubuntu systems."
        read -p "Continue anyway? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi

    # Install dependencies with error handling
    log "Updating package lists..."
    if ! sudo apt update; then
        log "Error: Failed to update package lists"
        exit 1
    fi

    log "Installing dependencies..."
    if ! sudo apt install -y software-properties-common build-essential wget curl git \
        libevent-dev libncurses-dev automake pkg-config bison libbz2-dev \
        libreadline-dev libsqlite3-dev libssl-dev libffi-dev zlib1g-dev \
        liblzma-dev llvm libncursesw5-dev xz-utils tk-dev libxml2-dev \
        libxmlsec1-dev libffi-dev liblzma-dev python3-dev python3-pip; then
        log "Error: Failed to install dependencies"
        exit 1
    fi

    # Install latest zsh
    log "Installing latest zsh..."
    # Always install the latest version available via apt
    sudo apt install -y zsh
    if command_exists zsh; then
        ZSH_VERSION=$(zsh --version | cut -d' ' -f2)
        log "zsh $ZSH_VERSION installed"
    fi

    # Install latest ranger
    log "Installing latest ranger..."
    # Always install the latest version available via pip
    pip3 install ranger-fm --upgrade
    if command_exists ranger; then
        RANGER_VERSION=$(ranger --version 2>&1 | head -n 1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
        log "ranger $RANGER_VERSION installed"
    fi

    # Install latest tmux
    log "Installing latest tmux..."
    # Always install the latest version available via apt
    sudo apt install -y tmux
    if command_exists tmux; then
        TMUX_VERSION=$(tmux -V | cut -d' ' -f2)
        log "tmux $TMUX_VERSION installed"
    fi

    # Install latest stable Neovim
    log "Installing latest stable Neovim..."
    # Always install the latest stable version by compiling from source

    # Install build dependencies for Neovim
    log "Installing build dependencies for Neovim..."
    if ! sudo apt install -y ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip git; then
        log "Error: Failed to install build dependencies for Neovim"
        exit 1
    fi

    # Clone the Neovim repository
    log "Cloning Neovim repository..."
    cd /tmp
    if [ -d "neovim" ]; then
        rm -rf neovim
    fi
    git clone https://github.com/neovim/neovim.git
    cd neovim

    # Get the latest stable release tag
    log "Finding latest stable release..."
    LATEST_TAG=$(git tag -l --sort=-v:refname | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | head -n 1)
    if [ -z "$LATEST_TAG" ]; then
        log "Error: Failed to find latest stable release tag"
        exit 1
    fi

    log "Checking out latest stable release: $LATEST_TAG"
    git checkout "$LATEST_TAG"

    # Build and install Neovim
    log "Building Neovim..."
    make CMAKE_BUILD_TYPE=Release
    log "Installing Neovim..."
    sudo make install

    # Clean up
    cd ..
    rm -rf neovim

    if command_exists nvim; then
        NVIM_VERSION=$(nvim --version | head -n 1)
        log "Neovim $NVIM_VERSION installed"
    fi

    # Install lazygit (latest stable release)
    log "Installing lazygit..."
    # Always install the latest version of lazygit
    cd /tmp
    LAZYGIT_URL=$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep browser_download_url | grep Linux_x86_64 | head -n 1 | cut -d '"' -f 4)
    if [ -z "$LAZYGIT_URL" ]; then
        log "Warning: Failed to find lazygit download URL, trying alternative method..."
        # Alternative method using the GitHub releases page directly
        LAZYGIT_VERSION=$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')
        if [ -z "$LAZYGIT_VERSION" ]; then
            log "Error: Failed to determine lazygit version"
            exit 1
        fi
        LAZYGIT_URL="https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    fi

    log "Downloading lazygit from: $LAZYGIT_URL"
    if ! wget "$LAZYGIT_URL" -O lazygit.tar.gz; then
        log "Error: Failed to download lazygit"
        exit 1
    fi

    tar xzf lazygit.tar.gz
    sudo install lazygit /usr/local/bin
    rm lazygit.tar.gz lazygit

    # Check installed version
    if command_exists lazygit; then
        LAZYGIT_VERSION=$(lazygit --version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
        log "lazygit $LAZYGIT_VERSION installed"
    else
        log "lazygit installed"
    fi

    # Install k9s (latest stable release)
    log "Installing k9s..."
    # Always install the latest version of k9s
    cd /tmp
    K9S_URL=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | grep browser_download_url | grep Linux_amd64 | head -n 1 | cut -d '"' -f 4)
    if [ -z "$K9S_URL" ]; then
        log "Warning: Failed to find k9s download URL, trying alternative method..."
        # Alternative method using the GitHub releases page directly
        K9S_VERSION=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')
        if [ -z "$K9S_VERSION" ]; then
            log "Error: Failed to determine k9s version"
            exit 1
        fi
        K9S_URL="https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/k9s_Linux_amd64.tar.gz"
    fi

    log "Downloading k9s from: $K9S_URL"
    if ! wget "$K9S_URL" -O k9s.tar.gz; then
        log "Error: Failed to download k9s"
        exit 1
    fi

    tar xzf k9s.tar.gz k9s
    sudo install k9s /usr/local/bin
    rm k9s.tar.gz k9s

    # Install Oh My Posh
    log "Installing Oh My Posh..."
    if curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/.local/bin; then
        log "Oh My Posh installed successfully"
    else
        log "Warning: Failed to install Oh My Posh"
    fi

    # Check installed version
    if command_exists ~/.local/bin/oh-my-posh; then
        OMP_VERSION=$($HOME/.local/bin/oh-my-posh --version)
        log "Oh My Posh $OMP_VERSION installed"
    fi

    # Check installed version
    if command_exists k9s; then
        K9S_VERSION_OUTPUT=$(k9s version 2>&1)
        K9S_VERSION=$(echo "$K9S_VERSION_OUTPUT" | grep Version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "")
        if [ -z "$K9S_VERSION" ]; then
            # Try alternative format
            K9S_VERSION=$(echo "$K9S_VERSION_OUTPUT" | head -n 1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
        fi
        log "k9s $K9S_VERSION installed"
    else
        log "k9s installed"
    fi

    # Verify installations
    log "Verifying installations..."
    log "ZSH version: $(zsh --version)"
    log "Ranger version: ranger $(ranger --version 2>&1 | head -n 1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
    log "Tmux version: $(tmux -V)"
    log "Neovim version: $(nvim --version | head -n 1)"
    if command_exists lazygit; then
        log "Lazygit version: $(lazygit --version 2>&1)"
    else
        log "Lazygit: Not installed"
    fi
    if command_exists k9s; then
        log "K9s version: $(k9s version 2>&1 | grep Version)"
    else
        log "K9s: Not installed"
    fi
    if command_exists ~/.local/bin/oh-my-posh; then
        log "Oh My Posh version: $($HOME/.local/bin/oh-my-posh --version)"
    else
        log "Oh My Posh: Not installed"
    fi

    log "All tools have been updated to their latest versions!"
}

# Function to apply configurations
apply_configs() {
    log "=== Applying dotfiles configurations ==="
    
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

    log "Dotfiles have been linked successfully!"
}

# Function to test ZSH configuration
test_config() {
    log "Testing ZSH configuration..."

    # Test 1: Check if zsh is installed
    if ! command -v zsh &> /dev/null; then
        log "FAIL: zsh is not installed"
        exit 1
    fi
    log "PASS: zsh is installed ($(zsh --version))"

    # Test 2: Check if .zshrc file exists
    if [ ! -f ~/.zshrc ]; then
        log "FAIL: ~/.zshrc does not exist"
        exit 1
    fi
    log "PASS: ~/.zshrc exists"

    # Test 3: Check if zsh can source .zshrc without critical errors
    log "Testing zsh configuration load..."
    zsh_output=$(zsh -c "source ~/.zshrc 2>&1" 2>&1)
    critical_errors=$(echo "$zsh_output" | grep -E "(command not found|syntax error|bad substitution)" | wc -l)

    if [ "$critical_errors" -gt 0 ]; then
        log "WARNING: Found $critical_errors potential issues when loading .zshrc:"
        echo "$zsh_output" | grep -E "(command not found|syntax error|bad substitution)" | head -5
    else
        log "PASS: .zshrc loads without critical errors"
    fi

    # Test 4: Check if required files exist
    required_files=(
        "$DOTFILES_DIR/zsh/oh-my-posh-config.json"
        "$DOTFILES_DIR/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
        "$DOTFILES_DIR/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
        "$DOTFILES_DIR/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh"
    )

    all_files_exist=true
    for file in "${required_files[@]}"; do
        if [ ! -f "$file" ]; then
            log "FAIL: Required file $file does not exist"
            all_files_exist=false
        fi
    done

    if [ "$all_files_exist" = true ]; then
        log "PASS: All required configuration files exist"
    fi

    log "ZSH configuration test completed."
}

# Function to set zsh as default shell
set_zsh_default() {
    log "=== Setting zsh as default shell ==="
    read -p "Do you want to set zsh as your default shell? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if chsh -s $(which zsh); then
            log "zsh has been set as your default shell. Log out and back in to apply changes."
        else
            log "Error: Failed to set zsh as default shell"
        fi
    fi
}

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

# Set zsh as default shell if requested and if tools were installed
if [[ "$SET_ZSH_DEFAULT" == true ]] && [[ "$INSTALL_TOOLS" == true ]]; then
    set_zsh_default
fi

log "=== Dotfiles management complete ==="
if [[ "$INSTALL_TOOLS" == true ]] && [[ "$APPLY_CONFIGS" == true ]]; then
    log "All tools installed and configurations applied."
elif [[ "$INSTALL_TOOLS" == true ]]; then
    log "Tools installation complete."
elif [[ "$APPLY_CONFIGS" == true ]]; then
    log "Configurations applied."
elif [[ "$TEST_CONFIG" == true ]]; then
    log "Configuration test completed."
fi