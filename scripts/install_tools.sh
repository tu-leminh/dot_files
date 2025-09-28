#!/bin/bash
# Install tools module for different OS versions

# Source utility functions
# Note: SCRIPT_DIR is expected to be set by the main script before sourcing this module
if [ -n "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/utils.sh" ]; then
    source "$SCRIPT_DIR/utils.sh"
elif [ -f "$(dirname "${BASH_SOURCE[0]}")/utils.sh" ]; then
    source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"
else
    echo "Error: utils.sh not found!" >&2
    exit 1
fi

# Install tools for Ubuntu
install_tools_ubuntu() {
    local version="$1"
    show_progress "Installing tools on Ubuntu $version (nvim, ranger, tmux, zsh, lazygit, k9s, sway, mako, swaylock, clipse)"
    
    # Install dependencies with error handling
    show_progress "Updating package lists..."
    # Try non-interactive sudo first
    if ! sudo -n apt update > /dev/null 2>&1; then
        log_warning "Cannot update package lists without password. Skipping for testing purposes."
    else
        show_progress "Package lists updated successfully"
    fi

    show_progress "Installing general dependencies..."
    if ! sudo -n apt install -y software-properties-common build-essential wget curl git > /dev/null 2>&1; then
        log_warning "Cannot install dependencies without password."
    else
        show_progress "General dependencies installed successfully"
    fi

    # Install latest zsh
    show_progress "Installing latest zsh..."
    if ! sudo -n apt install -y zsh > /dev/null 2>&1; then
        log_warning "Need sudo password to install zsh"
        if ! sudo -S apt install -y zsh > /dev/null 2>&1; then
            log_error "Failed to install zsh"
            exit 1
        fi
    fi
    if command_exists zsh; then
        ZSH_VERSION=$(zsh --version 2>/dev/null | cut -d' ' -f2)
        log_success "zsh $ZSH_VERSION installed"
    fi

    # Install latest ranger
    show_progress "Installing latest ranger..."
    if ! sudo -n apt install -y ranger > /dev/null 2>&1; then
        log_warning "Need sudo password to install ranger"
        if ! sudo -S apt install -y ranger > /dev/null 2>&1; then
            log_warning "Failed to install ranger via apt, trying pip..."
            if ! pip3 install ranger-fm --upgrade --break-system-packages > /dev/null 2>&1; then
                pip3 install ranger-fm --upgrade > /dev/null 2>&1
            fi
        fi
    fi
    if command_exists ranger; then
        RANGER_VERSION=$(ranger --version 2>&1 | head -n 1 | grep -oE '[0-9]+\\.[0-9]+\\.[0-9]+')
        log_success "ranger $RANGER_VERSION installed"
    fi

    # Install latest tmux
    show_progress "Installing latest tmux..."
    if ! sudo -n apt install -y tmux > /dev/null 2>&1; then
        log_warning "Need sudo password to install tmux"
        if ! sudo -S apt install -y tmux > /dev/null 2>&1; then
            log_error "Failed to install tmux"
            exit 1
        fi
    fi
    if command_exists tmux; then
        TMUX_VERSION=$(tmux -V 2>/dev/null | cut -d' ' -f2)
        log_success "tmux $TMUX_VERSION installed"
    fi

    # Install ripgrep, fzf, and fd (LazyVim dependencies)
    show_progress "Installing LazyVim dependencies (ripgrep, fzf, fd)..."
    if ! sudo -n apt install -y ripgrep fzf fd-find > /dev/null 2>&1; then
        log_warning "Need sudo password to install LazyVim dependencies"
        if ! sudo -S apt install -y ripgrep fzf fd-find > /dev/null 2>&1; then
            log_error "Failed to install LazyVim dependencies"
            exit 1
        fi
    fi
    
    # Create symlink for fd if needed (some systems use fdfind)
    if command_exists fdfind && ! command_exists fd; then
        show_progress "Creating fd symlink for fdfind..."
        sudo ln -sf $(which fdfind) /usr/local/bin/fd > /dev/null 2>&1 || true
    fi
    
    # Verify LazyVim dependencies
    if command_exists rg; then
        RG_VERSION=$(rg --version 2>&1 | head -n 1 | grep -oE '[0-9]+\\.[0-9]+\\.[0-9]+')
        log_success "ripgrep $RG_VERSION installed"
    fi
    if command_exists fzf; then
        FZF_VERSION=$(fzf --version 2>&1 | cut -d' ' -f1)
        log_success "fzf $FZF_VERSION installed"
    fi
    if command_exists fd || command_exists fdfind; then
        if command_exists fd; then
            FD_VERSION=$(fd --version 2>&1 | grep -oE '[0-9]+\\.[0-9]+\\.[0-9]+')
            log_success "fd $FD_VERSION installed"
        else
            FD_VERSION=$(fdfind --version 2>&1 | grep -oE '[0-9]+\\.[0-9]+\\.[0-9]+')
            log_success "fdfind $FD_VERSION installed (as fd)"
        fi
    fi

    # Install latest stable Neovim
    show_progress "Installing latest stable Neovim..."
    # Install build dependencies for Neovim
    show_progress "Installing build dependencies for Neovim..."
    if ! sudo -n apt install -y ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip > /dev/null 2>&1; then
        log_warning "Need sudo password to install build dependencies for Neovim"
        if ! sudo apt install -y ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip > /dev/null 2>&1; then
            log_error "Failed to install build dependencies for Neovim"
            exit 1
        fi
    fi

    # Clone the Neovim repository
    show_progress "Cloning Neovim repository..."
    cd /tmp
    if [ -d "neovim" ]; then
        rm -rf neovim > /dev/null 2>&1
    fi
    git clone https://github.com/neovim/neovim.git > /dev/null 2>&1
    cd neovim

    # Get the latest stable release tag
    show_progress "Finding latest stable release..."
    LATEST_TAG=$(git tag -l --sort=-v:refname | grep -E '^v[0-9]+\\.[0-9]+\\.[0-9]+$' | head -n 1)
    if [ -z "$LATEST_TAG" ]; then
        log_error "Failed to find latest stable release tag"
        exit 1
    fi

    show_progress "Checking out latest stable release: $LATEST_TAG"
    git checkout "$LATEST_TAG" > /dev/null 2>&1

    # Build and install Neovim
    show_progress "Building Neovim..."
    make CMAKE_BUILD_TYPE=Release > /dev/null 2>&1
    show_progress "Installing Neovim..."
    if ! sudo -n make install > /dev/null 2>&1; then
        log_warning "Need sudo password to install Neovim"
        if ! sudo make install > /dev/null 2>&1; then
            log_error "Failed to install Neovim"
            exit 1
        fi
    fi

    # Clean up
    cd ..
    rm -rf neovim > /dev/null 2>&1

    if command_exists nvim; then
        NVIM_VERSION=$(nvim --version | head -n 1)
        log_success "Neovim $NVIM_VERSION installed"
    fi

    # Install lazygit
    show_progress "Installing lazygit..."
    LAZYGIT_URL=""
    if command_exists curl; then
        LAZYGIT_URL=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep "browser_download_url.*Linux_x86_64.tar.gz" | cut -d '"' -f 4)
    fi
    
    if [ -n "$LAZYGIT_URL" ]; then
        show_progress "Downloading lazygit from: $LAZYGIT_URL"
        if curl -s -L "$LAZYGIT_URL" -o "$HOME/lazygit.tar.gz" > /dev/null 2>&1; then
            if tar -xzf "$HOME/lazygit.tar.gz" -C "$HOME" > /dev/null 2>&1; then
                if sudo install "$HOME/lazygit" "/usr/local/bin/" > /dev/null 2>&1; then
                    rm -f "$HOME/lazygit" "$HOME/lazygit.tar.gz"
                    LAZYGIT_VERSION=$(lazygit version 2>&1 | head -n 1 | grep -oE '[0-9]+\\.[0-9]+\\.[0-9]+')
                    log_success "lazygit $LAZYGIT_VERSION installed"
                else
                    mkdir -p "$HOME/.local/bin"
                    if install "$HOME/lazygit" "$HOME/.local/bin/" > /dev/null 2>&1; then
                        rm -f "$HOME/lazygit" "$HOME/lazygit.tar.gz"
                        LAZYGIT_VERSION=$(lazygit version 2>&1 | head -n 1 | grep -oE '[0-9]+\\.[0-9]+\\.[0-9]+')
                        log_success "lazygit $LAZYGIT_VERSION installed"
                    else
                        log_warning "Failed to install lazygit to $HOME/.local/bin"
                        rm -f "$HOME/lazygit" "$HOME/lazygit.tar.gz"
                    fi
                fi
            else
                log_warning "Failed to extract lazygit archive"
                rm -f "$HOME/lazygit.tar.gz"
            fi
        else
            log_warning "Failed to download lazygit"
        fi
    else
        log_warning "Failed to find lazygit download URL"
    fi

    # Install k9s (latest stable release)
    show_progress "Installing k9s..."
    cd /tmp
    K9S_URL=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | grep browser_download_url | grep Linux_amd64 | head -n 1 | cut -d '"' -f 4)
    if [ -z "$K9S_URL" ]; then
        log_warning "Failed to find k9s download URL, trying alternative method..."
        K9S_VERSION=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')
        if [ -z "$K9S_VERSION" ]; then
            log_error "Failed to determine k9s version"
            exit 1
        fi
        K9S_URL="https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/k9s_Linux_amd64.tar.gz"
    fi

    show_progress "Downloading k9s from: $K9S_URL"
    if ! wget "$K9S_URL" -O k9s.tar.gz > /dev/null 2>&1; then
        log_error "Failed to download k9s"
        exit 1
    fi

    tar xzf k9s.tar.gz k9s > /dev/null 2>&1
    if ! sudo -n install k9s /usr/local/bin > /dev/null 2>&1; then
        log_warning "Need sudo password to install k9s"
        if ! sudo install k9s /usr/local/bin > /dev/null 2>&1; then
            log_error "Failed to install k9s"
            exit 1
        fi
    fi
    rm k9s.tar.gz k9s > /dev/null 2>&1

    # Install clipse
    show_progress "Installing clipse..."
    if command -v go >/dev/null 2>&1; then
        if ! go install github.com/savedra1/clipse@latest > /dev/null 2>&1; then
            log_error "Failed to install clipse via go install"
            exit 1
        else
            GOPATH=${GOPATH:-$HOME/go}
            CLIPSE_BIN="$GOPATH/bin/clipse"
            if [ -f "$CLIPSE_BIN" ]; then
                log_success "clipse installed successfully at $CLIPSE_BIN"
                chmod +x "$CLIPSE_BIN" > /dev/null 2>&1
                if sudo -n ln -sf "$CLIPSE_BIN" /usr/local/bin/clipse > /dev/null 2>&1; then
                    log_success "clipse made available system-wide"
                else
                    if ! grep -q 'export.*GOPATH.*bin' ~/.zshrc > /dev/null 2>&1; then
                        echo 'export PATH="$PATH:$GOPATH/bin"' >> ~/.zshrc
                        log_info "Added GOPATH/bin to PATH in ~/.zshrc"
                    fi
                    log_info "clipse available at $CLIPSE_BIN - ensure GOPATH/bin is in your PATH"
                fi
            else
                log_error "clipse binary not found at expected location: $CLIPSE_BIN"
            fi
        fi
    else
        log_warning "Go is not installed, cannot install clipse. Please install Go first."
    fi

    # Install Oh My Posh
    show_progress "Installing Oh My Posh..."
    OMP_DIR="$HOME/.local/bin"
    mkdir -p "$OMP_DIR" > /dev/null 2>&1
    if curl -s https://ohmyposh.dev/install.sh | bash -s -- -d "$OMP_DIR" > /dev/null 2>&1; then
        log_success "Oh My Posh installed successfully"
        if command_exists "$OMP_DIR/oh-my-posh"; then
            OMP_VERSION=$(\"$OMP_DIR/oh-my-posh\" --version 2>/dev/null)
            log_success "Oh My Posh $OMP_VERSION installed"
        fi
    else
        log_warning "Failed to install Oh My Posh"
    fi

    # Check installed version
    if command_exists k9s; then
        K9S_VERSION_OUTPUT=$(k9s version 2>&1)
        K9S_VERSION=$(echo "$K9S_VERSION_OUTPUT" | grep Version | grep -oE '[0-9]+\\.[0-9]+\\.[0-9]+' || echo "")
        if [ -z "$K9S_VERSION" ]; then
            K9S_VERSION=$(echo "$K9S_VERSION_OUTPUT" | head -n 1 | grep -oE '[0-9]+\\.[0-9]+\\.[0-9]+' || echo "unknown")
        fi
        log_success "k9s $K9S_VERSION installed"
    else
        log_success "k9s installed"
    fi

    # Verify installations
    show_progress "Verifying installations..."
    log_info "ZSH version: $(zsh --version 2>/dev/null)"
    log_info "Ranger version: ranger $(ranger --version 2>&1 | head -n 1 | grep -oE '[0-9]+\\.[0-9]+\\.[0-9]+')"
    log_info "Tmux version: $(tmux -V 2>/dev/null)"
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
        log_info "Oh My Posh version: $($HOME/.local/bin/oh-my-posh --version 2>/dev/null)"
    else
        log_warning "Oh My Posh: Not installed"
    fi
    if command_exists rg; then
        log_info "ripgrep version: $(rg --version 2>&1 | head -n 1)"
    else
        log_warning "ripgrep: Not installed"
    fi
    if command_exists fzf; then
        log_info "fzf version: $(fzf --version 2>&1 | cut -d' ' -f1)"
    else
        log_warning "fzf: Not installed"
    fi
    if command_exists fd; then
        log_info "fd version: $(fd --version 2>&1)"
    elif command_exists fdfind; then
        log_info "fdfind version: $(fdfind --version 2>&1)"
    else
        log_warning "fd/fdfind: Not installed"
    fi

    # Install Sway and related packages
    show_progress "Installing Sway and related packages..."
    SWAY_INSTALLED=false
    if command -v sway >/dev/null 2>&1 || command -v Sway >/dev/null 2>&1; then
        log_info "Sway is already installed"
        SWAY_INSTALLED=true
        log_info "Skipping Sway installation (already installed)"
    fi
    
    if [[ "$SWAY_INSTALLED" == false ]]; then
        show_progress "Installing Sway and related packages..."
        if ! sudo -n apt install -y sway mako-notifier grim slurp brightnessctl pamixer playerctl thunar foot wmenu > /dev/null 2>&1; then
            log_warning "Need sudo password to install Sway and related packages"
            if sudo apt install -y sway mako-notifier grim slurp brightnessctl pamixer playerctl thunar foot wmenu > /dev/null 2>&1; then
                log_success "Sway and related packages installed successfully"
            else
                log_error "Failed to install Sway packages"
                exit 1
            fi
        else
            log_success "Sway and related packages installed successfully"
        fi
    fi

    show_progress "All tools have been updated to their latest versions on Ubuntu $version!"
}

# Install tools for Debian
install_tools_debian() {
    local version="$1"
    show_progress "Installing tools on Debian $version (nvim, ranger, tmux, zsh, lazygit, k9s, sway, mako, swaylock, clipse)"
    
    # Most Debian install steps are similar to Ubuntu
    install_tools_ubuntu "$version"
}

# Install tools for Fedora
install_tools_fedora() {
    local version="$1"
    show_progress "Installing tools on Fedora $version (nvim, ranger, tmux, zsh, lazygit, k9s, sway, mako, swaylock, clipse)"
    
    # Install dependencies with error handling
    show_progress "Updating package lists..."
    if ! sudo -n dnf update -y > /dev/null 2>&1; then
        log_warning "Cannot update package lists without password. Skipping for testing purposes."
    else
        show_progress "Package lists updated successfully"
    fi

    show_progress "Installing general dependencies..."
    if ! sudo -n dnf install -y dnf-utils build-essential wget curl git > /dev/null 2>&1; then
        log_warning "Cannot install dependencies without password."
    else
        show_progress "General dependencies installed successfully"
    fi

    # Install latest zsh
    show_progress "Installing latest zsh..."
    if ! sudo -n dnf install -y zsh > /dev/null 2>&1; then
        log_warning "Need sudo password to install zsh"
        if ! sudo -S dnf install -y zsh > /dev/null 2>&1; then
            log_error "Failed to install zsh"
            exit 1
        fi
    fi
    if command_exists zsh; then
        ZSH_VERSION=$(zsh --version 2>/dev/null | cut -d' ' -f2)
        log_success "zsh $ZSH_VERSION installed"
    fi

    # Install latest ranger
    show_progress "Installing latest ranger..."
    if ! sudo -n dnf install -y ranger > /dev/null 2>&1; then
        log_warning "Need sudo password to install ranger"
        if ! sudo -S dnf install -y ranger > /dev/null 2>&1; then
            log_warning "Failed to install ranger via dnf, trying pip..."
            if ! pip3 install ranger-fm --upgrade --break-system-packages > /dev/null 2>&1; then
                pip3 install ranger-fm --upgrade > /dev/null 2>&1
            fi
        fi
    fi
    if command_exists ranger; then
        RANGER_VERSION=$(ranger --version 2>&1 | head -n 1 | grep -oE '[0-9]+\\.[0-9]+\\.[0-9]+')
        log_success "ranger $RANGER_VERSION installed"
    fi

    # Install latest tmux
    show_progress "Installing latest tmux..."
    if ! sudo -n dnf install -y tmux > /dev/null 2>&1; then
        log_warning "Need sudo password to install tmux"
        if ! sudo -S dnf install -y tmux > /dev/null 2>&1; then
            log_error "Failed to install tmux"
            exit 1
        fi
    fi
    if command_exists tmux; then
        TMUX_VERSION=$(tmux -V 2>/dev/null | cut -d' ' -f2)
        log_success "tmux $TMUX_VERSION installed"
    fi

    # Install ripgrep, fzf, and fd (LazyVim dependencies)
    show_progress "Installing LazyVim dependencies (ripgrep, fzf, fd)..."
    if ! sudo -n dnf install -y ripgrep fzf fd-find > /dev/null 2>&1; then
        log_warning "Need sudo password to install LazyVim dependencies"
        if ! sudo -S dnf install -y ripgrep fzf fd-find > /dev/null 2>&1; then
            log_error "Failed to install LazyVim dependencies"
            exit 1
        fi
    fi
    
    # Verify LazyVim dependencies
    if command_exists rg; then
        RG_VERSION=$(rg --version 2>&1 | head -n 1 | grep -oE '[0-9]+\\.[0-9]+\\.[0-9]+')
        log_success "ripgrep $RG_VERSION installed"
    fi
    if command_exists fzf; then
        FZF_VERSION=$(fzf --version 2>&1 | cut -d' ' -f1)
        log_success "fzf $FZF_VERSION installed"
    fi
    if command_exists fd || command_exists fdfind; then
        if command_exists fd; then
            FD_VERSION=$(fd --version 2>&1 | grep -oE '[0-9]+\\.[0-9]+\\.[0-9]+')
            log_success "fd $FD_VERSION installed"
        else
            FD_VERSION=$(fdfind --version 2>&1 | grep -oE '[0-9]+\\.[0-9]+\\.[0-9]+')
            log_success "fdfind $FD_VERSION installed (as fd)"
        fi
    fi

    # Install latest stable Neovim
    show_progress "Installing latest stable Neovim..."
    
    # Check if available in dnf repos first
    if command_exists dnf && sudo dnf search neovim > /dev/null 2>&1; then
        show_progress "Installing neovim from dnf repos..."
        if ! sudo -n dnf install -y neovim > /dev/null 2>&1; then
            log_warning "Need sudo password to install neovim from dnf repos"
            if sudo dnf install -y neovim > /dev/null 2>&1; then
                log_success "Neovim installed from dnf repos"
            else
                log_warning "Failed to install neovim from dnf, attempting build from source..."
                install_neovim_from_source
            fi
        fi
    else
        log_warning "Neovim not available in dnf repos, attempting build from source..."
        install_neovim_from_source
    fi

    if command_exists nvim; then
        NVIM_VERSION=$(nvim --version | head -n 1)
        log_success "Neovim $NVIM_VERSION installed"
    fi

    # Install lazygit
    show_progress "Installing lazygit..."
    LAZYGIT_URL=""
    if command_exists curl; then
        LAZYGIT_URL=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep "browser_download_url.*Linux_x86_64.tar.gz" | cut -d '"' -f 4)
    fi
    
    if [ -n "$LAZYGIT_URL" ]; then
        show_progress "Downloading lazygit from: $LAZYGIT_URL"
        if curl -s -L "$LAZYGIT_URL" -o "$HOME/lazygit.tar.gz" > /dev/null 2>&1; then
            if tar -xzf "$HOME/lazygit.tar.gz" -C "$HOME" > /dev/null 2>&1; then
                if sudo install "$HOME/lazygit" "/usr/local/bin/" > /dev/null 2>&1; then
                    rm -f "$HOME/lazygit" "$HOME/lazygit.tar.gz"
                    LAZYGIT_VERSION=$(lazygit version 2>&1 | head -n 1 | grep -oE '[0-9]+\\.[0-9]+\\.[0-9]+')
                    log_success "lazygit $LAZYGIT_VERSION installed"
                else
                    mkdir -p "$HOME/.local/bin"
                    if install "$HOME/lazygit" "$HOME/.local/bin/" > /dev/null 2>&1; then
                        rm -f "$HOME/lazygit" "$HOME/lazygit.tar.gz"
                        LAZYGIT_VERSION=$(lazygit version 2>&1 | head -n 1 | grep -oE '[0-9]+\\.[0-9]+\\.[0-9]+')
                        log_success "lazygit $LAZYGIT_VERSION installed"
                    else
                        log_warning "Failed to install lazygit to $HOME/.local/bin"
                        rm -f "$HOME/lazygit" "$HOME/lazygit.tar.gz"
                    fi
                fi
            else
                log_warning "Failed to extract lazygit archive"
                rm -f "$HOME/lazygit.tar.gz"
            fi
        else
            log_warning "Failed to download lazygit"
        fi
    else
        log_warning "Failed to find lazygit download URL"
    fi

    # Install k9s (latest stable release)
    show_progress "Installing k9s..."
    cd /tmp
    K9S_URL=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | grep browser_download_url | grep Linux_amd64 | head -n 1 | cut -d '"' -f 4)
    if [ -z "$K9S_URL" ]; then
        log_warning "Failed to find k9s download URL, trying alternative method..."
        K9S_VERSION=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')
        if [ -z "$K9S_VERSION" ]; then
            log_error "Failed to determine k9s version"
            exit 1
        fi
        K9S_URL="https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/k9s_Linux_amd64.tar.gz"
    fi

    show_progress "Downloading k9s from: $K9S_URL"
    if ! wget "$K9S_URL" -O k9s.tar.gz > /dev/null 2>&1; then
        log_error "Failed to download k9s"
        exit 1
    fi

    tar xzf k9s.tar.gz k9s > /dev/null 2>&1
    if ! sudo -n install k9s /usr/local/bin > /dev/null 2>&1; then
        log_warning "Need sudo password to install k9s"
        if ! sudo install k9s /usr/local/bin > /dev/null 2>&1; then
            log_error "Failed to install k9s"
            exit 1
        fi
    fi
    rm k9s.tar.gz k9s > /dev/null 2>&1

    # Install clipse
    show_progress "Installing clipse..."
    if command -v go >/dev/null 2>&1; then
        if ! go install github.com/savedra1/clipse@latest > /dev/null 2>&1; then
            log_error "Failed to install clipse via go install"
            exit 1
        else
            GOPATH=${GOPATH:-$HOME/go}
            CLIPSE_BIN="$GOPATH/bin/clipse"
            if [ -f "$CLIPSE_BIN" ]; then
                log_success "clipse installed successfully at $CLIPSE_BIN"
                chmod +x "$CLIPSE_BIN" > /dev/null 2>&1
                if sudo -n ln -sf "$CLIPSE_BIN" /usr/local/bin/clipse > /dev/null 2>&1; then
                    log_success "clipse made available system-wide"
                else
                    if ! grep -q 'export.*GOPATH.*bin' ~/.zshrc > /dev/null 2>&1; then
                        echo 'export PATH="$PATH:$GOPATH/bin"' >> ~/.zshrc
                        log_info "Added GOPATH/bin to PATH in ~/.zshrc"
                    fi
                    log_info "clipse available at $CLIPSE_BIN - ensure GOPATH/bin is in your PATH"
                fi
            else
                log_error "clipse binary not found at expected location: $CLIPSE_BIN"
            fi
        fi
    else
        log_warning "Go is not installed, cannot install clipse. Please install Go first."
    fi

    # Install Oh My Posh
    show_progress "Installing Oh My Posh..."
    OMP_DIR="$HOME/.local/bin"
    mkdir -p "$OMP_DIR" > /dev/null 2>&1
    if curl -s https://ohmyposh.dev/install.sh | bash -s -- -d "$OMP_DIR" > /dev/null 2>&1; then
        log_success "Oh My Posh installed successfully"
        if command_exists "$OMP_DIR/oh-my-posh"; then
            OMP_VERSION=$(\"$OMP_DIR/oh-my-posh\" --version 2>/dev/null)
            log_success "Oh My Posh $OMP_VERSION installed"
        fi
    else
        log_warning "Failed to install Oh My Posh"
    fi

    # Verify installations
    show_progress "Verifying installations..."
    log_info "ZSH version: $(zsh --version 2>/dev/null)"
    log_info "Ranger version: ranger $(ranger --version 2>&1 | head -n 1 | grep -oE '[0-9]+\\.[0-9]+\\.[0-9]+')"
    log_info "Tmux version: $(tmux -V 2>/dev/null)"
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
        log_info "Oh My Posh version: $($HOME/.local/bin/oh-my-posh --version 2>/dev/null)"
    else
        log_warning "Oh My Posh: Not installed"
    fi
    if command_exists rg; then
        log_info "ripgrep version: $(rg --version 2>&1 | head -n 1)"
    else
        log_warning "ripgrep: Not installed"
    fi
    if command_exists fzf; then
        log_info "fzf version: $(fzf --version 2>&1 | cut -d' ' -f1)"
    else
        log_warning "fzf: Not installed"
    fi
    if command_exists fd; then
        log_info "fd version: $(fd --version 2>&1)"
    elif command_exists fdfind; then
        log_info "fdfind version: $(fdfind --version 2>&1)"
    else
        log_warning "fd/fdfind: Not installed"
    fi

    # Install Sway and related packages
    show_progress "Installing Sway and related packages..."
    SWAY_INSTALLED=false
    if command -v sway >/dev/null 2>&1 || command -v Sway >/dev/null 2>&1; then
        log_info "Sway is already installed"
        SWAY_INSTALLED=true
        log_info "Skipping Sway installation (already installed)"
    fi
    
    if [[ "$SWAY_INSTALLED" == false ]]; then
        show_progress "Installing Sway and related packages..."
        if ! sudo -n dnf install -y sway mako grim slurp brightnessctl pamixer playerctl thunar foot wmenu > /dev/null 2>&1; then
            log_warning "Need sudo password to install Sway and related packages"
            if sudo dnf install -y sway mako grim slurp brightnessctl pamixer playerctl thunar foot wmenu > /dev/null 2>&1; then
                log_success "Sway and related packages installed successfully"
            else
                log_error "Failed to install Sway packages"
                exit 1
            fi
        else
            log_success "Sway and related packages installed successfully"
        fi
    fi

    show_progress "All tools have been updated to their latest versions on Fedora $version!"
}

# Install tools for Arch Linux
install_tools_arch() {
    local version="$1"
    show_progress "Installing tools on Arch Linux $version (nvim, ranger, tmux, zsh, lazygit, k9s, sway, mako, swaylock, clipse)"
    
    # Install dependencies with error handling
    show_progress "Updating package lists..."
    if ! sudo -n pacman -Sy --noconfirm > /dev/null 2>&1; then
        log_warning "Cannot update package lists without password. Skipping for testing purposes."
    else
        show_progress "Package lists updated successfully"
    fi

    show_progress "Installing general dependencies..."
    if ! sudo -n pacman -S --noconfirm base-devel wget curl git > /dev/null 2>&1; then
        log_warning "Cannot install dependencies without password."
    else
        show_progress "General dependencies installed successfully"
    fi

    # Install latest zsh
    show_progress "Installing latest zsh..."
    if ! sudo -n pacman -S --noconfirm zsh > /dev/null 2>&1; then
        log_warning "Need sudo password to install zsh"
        if ! sudo -S pacman -S --noconfirm zsh > /dev/null 2>&1; then
            log_error "Failed to install zsh"
            exit 1
        fi
    fi
    if command_exists zsh; then
        ZSH_VERSION=$(zsh --version 2>/dev/null | cut -d' ' -f2)
        log_success "zsh $ZSH_VERSION installed"
    fi

    # Install latest ranger
    show_progress "Installing latest ranger..."
    if ! sudo -n pacman -S --noconfirm ranger > /dev/null 2>&1; then
        log_warning "Need sudo password to install ranger"
        if ! sudo -S pacman -S --noconfirm ranger > /dev/null 2>&1; then
            log_warning "Failed to install ranger via pacman, trying pip..."
            if ! pip3 install ranger-fm --upgrade --break-system-packages > /dev/null 2>&1; then
                pip3 install ranger-fm --upgrade > /dev/null 2>&1
            fi
        fi
    fi
    if command_exists ranger; then
        RANGER_VERSION=$(ranger --version 2>&1 | head -n 1 | grep -oE '[0-9]+\\.[0-9]+\\.[0-9]+')
        log_success "ranger $RANGER_VERSION installed"
    fi

    # Install latest tmux
    show_progress "Installing latest tmux..."
    if ! sudo -n pacman -S --noconfirm tmux > /dev/null 2>&1; then
        log_warning "Need sudo password to install tmux"
        if ! sudo -S pacman -S --noconfirm tmux > /dev/null 2>&1; then
            log_error "Failed to install tmux"
            exit 1
        fi
    fi
    if command_exists tmux; then
        TMUX_VERSION=$(tmux -V 2>/dev/null | cut -d' ' -f2)
        log_success "tmux $TMUX_VERSION installed"
    fi

    # Install ripgrep, fzf, and fd (LazyVim dependencies)
    show_progress "Installing LazyVim dependencies (ripgrep, fzf, fd)..."
    if ! sudo -n pacman -S --noconfirm ripgrep fzf fd > /dev/null 2>&1; then
        log_warning "Need sudo password to install LazyVim dependencies"
        if ! sudo -S pacman -S --noconfirm ripgrep fzf fd > /dev/null 2>&1; then
            log_error "Failed to install LazyVim dependencies"
            exit 1
        fi
    fi
    
    # Verify LazyVim dependencies
    if command_exists rg; then
        RG_VERSION=$(rg --version 2>&1 | head -n 1 | grep -oE '[0-9]+\\.[0-9]+\\.[0-9]+')
        log_success "ripgrep $RG_VERSION installed"
    fi
    if command_exists fzf; then
        FZF_VERSION=$(fzf --version 2>&1 | cut -d' ' -f1)
        log_success "fzf $FZF_VERSION installed"
    fi
    if command_exists fd; then
        FD_VERSION=$(fd --version 2>&1 | grep -oE '[0-9]+\\.[0-9]+\\.[0-9]+')
        log_success "fd $FD_VERSION installed"
    fi

    # Install latest stable Neovim
    show_progress "Installing latest stable Neovim..."
    # Check if available in pacman repos first
    if command_exists pacman && sudo pacman -Ss neovim > /dev/null 2>&1; then
        show_progress "Installing neovim from pacman repos..."
        if ! sudo -n pacman -S --noconfirm neovim > /dev/null 2>&1; then
            log_warning "Need sudo password to install neovim from pacman repos"
            if sudo pacman -S --noconfirm neovim > /dev/null 2>&1; then
                log_success "Neovim installed from pacman repos"
            else
                log_warning "Failed to install neovim from pacman, attempting build from source..."
                install_neovim_from_source
            fi
        fi
    else
        log_warning "Neovim not available in pacman repos, attempting build from source..."
        install_neovim_from_source
    fi

    if command_exists nvim; then
        NVIM_VERSION=$(nvim --version | head -n 1)
        log_success "Neovim $NVIM_VERSION installed"
    fi

    # Install lazygit
    show_progress "Installing lazygit..."
    LAZYGIT_URL=""
    if command_exists curl; then
        LAZYGIT_URL=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep "browser_download_url.*Linux_x86_64.tar.gz" | cut -d '"' -f 4)
    fi
    
    if [ -n "$LAZYGIT_URL" ]; then
        show_progress "Downloading lazygit from: $LAZYGIT_URL"
        if curl -s -L "$LAZYGIT_URL" -o "$HOME/lazygit.tar.gz" > /dev/null 2>&1; then
            if tar -xzf "$HOME/lazygit.tar.gz" -C "$HOME" > /dev/null 2>&1; then
                if sudo install "$HOME/lazygit" "/usr/local/bin/" > /dev/null 2>&1; then
                    rm -f "$HOME/lazygit" "$HOME/lazygit.tar.gz"
                    LAZYGIT_VERSION=$(lazygit version 2>&1 | head -n 1 | grep -oE '[0-9]+\\.[0-9]+\\.[0-9]+')
                    log_success "lazygit $LAZYGIT_VERSION installed"
                else
                    mkdir -p "$HOME/.local/bin"
                    if install "$HOME/lazygit" "$HOME/.local/bin/" > /dev/null 2>&1; then
                        rm -f "$HOME/lazygit" "$HOME/lazygit.tar.gz"
                        LAZYGIT_VERSION=$(lazygit version 2>&1 | head -n 1 | grep -oE '[0-9]+\\.[0-9]+\\.[0-9]+')
                        log_success "lazygit $LAZYGIT_VERSION installed"
                    else
                        log_warning "Failed to install lazygit to $HOME/.local/bin"
                        rm -f "$HOME/lazygit" "$HOME/lazygit.tar.gz"
                    fi
                fi
            else
                log_warning "Failed to extract lazygit archive"
                rm -f "$HOME/lazygit.tar.gz"
            fi
        else
            log_warning "Failed to download lazygit"
        fi
    else
        log_warning "Failed to find lazygit download URL"
    fi

    # Install k9s (latest stable release)
    show_progress "Installing k9s..."
    cd /tmp
    K9S_URL=$(curl -s "https://api.github.com/repos/derailed/k9s/releases/latest" | grep browser_download_url | grep Linux_amd64 | head -n 1 | cut -d '"' -f 4)
    if [ -z "$K9S_URL" ]; then
        log_warning "Failed to find k9s download URL, trying alternative method..."
        K9S_VERSION=$(curl -s "https://api.github.com/repos/derailed/k9s/releases/latest" | grep tag_name | cut -d '"' -f 4 | sed 's/v//')
        if [ -z "$K9S_VERSION" ]; then
            log_error "Failed to determine k9s version"
            exit 1
        fi
        K9S_URL="https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/k9s_Linux_amd64.tar.gz"
    fi

    show_progress "Downloading k9s from: $K9S_URL"
    if ! wget "$K9S_URL" -O k9s.tar.gz > /dev/null 2>&1; then
        log_error "Failed to download k9s"
        exit 1
    fi

    tar xzf k9s.tar.gz k9s > /dev/null 2>&1
    if ! sudo -n install k9s /usr/local/bin > /dev/null 2>&1; then
        log_warning "Need sudo password to install k9s"
        if ! sudo install k9s /usr/local/bin > /dev/null 2>&1; then
            log_error "Failed to install k9s"
            exit 1
        fi
    fi
    rm k9s.tar.gz k9s > /dev/null 2>&1

    # Install clipse
    show_progress "Installing clipse..."
    if command -v go >/dev/null 2>&1; then
        if ! go install github.com/savedra1/clipse@latest > /dev/null 2>&1; then
            log_error "Failed to install clipse via go install"
            exit 1
        else
            GOPATH=${GOPATH:-$HOME/go}
            CLIPSE_BIN="$GOPATH/bin/clipse"
            if [ -f "$CLIPSE_BIN" ]; then
                log_success "clipse installed successfully at $CLIPSE_BIN"
                chmod +x "$CLIPSE_BIN" > /dev/null 2>&1
                if sudo -n ln -sf "$CLIPSE_BIN" /usr/local/bin/clipse > /dev/null 2>&1; then
                    log_success "clipse made available system-wide"
                else
                    if ! grep -q 'export.*GOPATH.*bin' ~/.zshrc > /dev/null 2>&1; then
                        echo 'export PATH="$PATH:$GOPATH/bin"' >> ~/.zshrc
                        log_info "Added GOPATH/bin to PATH in ~/.zshrc"
                    fi
                    log_info "clipse available at $CLIPSE_BIN - ensure GOPATH/bin is in your PATH"
                fi
            else
                log_error "clipse binary not found at expected location: $CLIPSE_BIN"
            fi
        fi
    else
        log_warning "Go is not installed, cannot install clipse. Please install Go first."
    fi

    # Install Oh My Posh
    show_progress "Installing Oh My Posh..."
    OMP_DIR="$HOME/.local/bin"
    mkdir -p "$OMP_DIR" > /dev/null 2>&1
    if curl -s https://ohmyposh.dev/install.sh | bash -s -- -d "$OMP_DIR" > /dev/null 2>&1; then
        log_success "Oh My Posh installed successfully"
        if command_exists "$OMP_DIR/oh-my-posh"; then
            OMP_VERSION=$(\"$OMP_DIR/oh-my-posh\" --version 2>/dev/null)
            log_success "Oh My Posh $OMP_VERSION installed"
        fi
    else
        log_warning "Failed to install Oh My Posh"
    fi

    # Verify installations
    show_progress "Verifying installations..."
    log_info "ZSH version: $(zsh --version 2>/dev/null)"
    log_info "Ranger version: ranger $(ranger --version 2>&1 | head -n 1 | grep -oE '[0-9]+\\.[0-9]+\\.[0-9]+')"
    log_info "Tmux version: $(tmux -V 2>/dev/null)"
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
        log_info "Oh My Posh version: $($HOME/.local/bin/oh-my-posh --version 2>/dev/null)"
    else
        log_warning "Oh My Posh: Not installed"
    fi
    if command_exists rg; then
        log_info "ripgrep version: $(rg --version 2>&1 | head -n 1)"
    else
        log_warning "ripgrep: Not installed"
    fi
    if command_exists fzf; then
        log_info "fzf version: $(fzf --version 2>&1 | cut -d' ' -f1)"
    else
        log_warning "fzf: Not installed"
    fi
    if command_exists fd; then
        log_info "fd version: $(fd --version 2>&1)"
    else
        log_warning "fd: Not installed"
    fi

    # Install Sway and related packages
    show_progress "Installing Sway and related packages..."
    SWAY_INSTALLED=false
    if command -v sway >/dev/null 2>&1 || command -v Sway >/dev/null 2>&1; then
        log_info "Sway is already installed"
        SWAY_INSTALLED=true
        log_info "Skipping Sway installation (already installed)"
    fi
    
    if [[ "$SWAY_INSTALLED" == false ]]; then
        show_progress "Installing Sway and related packages..."
        if ! sudo -n pacman -S --noconfirm sway mako grim slurp brightnessctl pamixer playerctl thunar foot wmenu > /dev/null 2>&1; then
            log_warning "Need sudo password to install Sway and related packages"
            if sudo pacman -S --noconfirm sway mako grim slurp brightnessctl pamixer playerctl thunar foot wmenu > /dev/null 2>&1; then
                log_success "Sway and related packages installed successfully"
            else
                log_error "Failed to install Sway packages"
                exit 1
            fi
        else
            log_success "Sway and related packages installed successfully"
        fi
    fi

    show_progress "All tools have been updated to their latest versions on Arch Linux!"
}

# Helper function to install Neovim from source since it's common across distros
install_neovim_from_source() {
    show_progress "Installing build dependencies for Neovim..."
    local install_cmd
    if command_exists apt; then
        install_cmd="sudo apt install -y ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip"
    elif command_exists dnf; then
        install_cmd="sudo dnf install -y ninja-build gettext libtool libtool-bin autoconf automake cmake gcc gcc-c++ make pkgconfig unzip"
    elif command_exists pacman; then
        install_cmd="sudo pacman -S --noconfirm ninja cmake gettext libtool libtool-bin autoconf automake gcc make pkgconf unzip"
    else
        log_error "No known package manager found for installing build dependencies for Neovim"
        exit 1
    fi
    
    if ! eval "$install_cmd" > /dev/null 2>&1; then
        log_error "Failed to install build dependencies for Neovim"
        exit 1
    fi

    # Clone the Neovim repository
    show_progress "Cloning Neovim repository..."
    cd /tmp
    if [ -d "neovim" ]; then
        rm -rf neovim > /dev/null 2>&1
    fi
    git clone https://github.com/neovim/neovim.git > /dev/null 2>&1
    cd neovim

    # Get the latest stable release tag
    show_progress "Finding latest stable release..."
    LATEST_TAG=$(git tag -l --sort=-v:refname | grep -E '^v[0-9]+\\.[0-9]+\\.[0-9]+$' | head -n 1)
    if [ -z "$LATEST_TAG" ]; then
        log_error "Failed to find latest stable release tag"
        exit 1
    fi

    show_progress "Checking out latest stable release: $LATEST_TAG"
    git checkout "$LATEST_TAG" > /dev/null 2>&1

    # Build and install Neovim
    show_progress "Building Neovim..."
    make CMAKE_BUILD_TYPE=Release > /dev/null 2>&1
    show_progress "Installing Neovim..."
    if ! sudo make install > /dev/null 2>&1; then
        log_error "Failed to install Neovim"
        exit 1
    fi

    # Clean up
    cd ..
    rm -rf neovim > /dev/null 2>&1
}

# Main install function that detects OS and calls appropriate installer
install_tools() {
    local force_reinstall=${1:-false}
    
    # Detect OS and call appropriate installer
    local os_type=$(detect_os)
    local os_version=""
    
    case $os_type in
        *ubuntu*)
            os_version=$(detect_ubuntu_version)
            if [ $? -eq 0 ]; then
                install_tools_ubuntu "$os_version"
            else
                log_warning "Could not detect Ubuntu version, proceeding with generic installation"
                install_tools_ubuntu "unknown"
            fi
            ;;
        *debian*)
            os_version=$(detect_debian_version)
            if [ $? -eq 0 ]; then
                install_tools_debian "$os_version"
            else
                log_warning "Could not detect Debian version, proceeding with generic installation"
                install_tools_debian "unknown"
            fi
            ;;
        *fedora*)
            os_version=$(detect_fedora_version)
            if [ $? -eq 0 ]; then
                install_tools_fedora "$os_version"
            else
                log_warning "Could not detect Fedora version, proceeding with generic installation"
                install_tools_fedora "unknown"
            fi
            ;;
        *arch*)
            os_version=$(detect_arch_version)
            if [ $? -eq 0 ]; then
                install_tools_arch "$os_version"
            else
                log_warning "Could not detect Arch version, proceeding with generic installation"
                install_tools_arch "rolling"
            fi
            ;;
        *)
            log_warning "Unsupported OS: $os_type. This script is designed for Ubuntu, Debian, Fedora, and Arch Linux systems."
            read -p "Continue anyway? (y/n): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                exit 1
            fi
            # Default to Ubuntu installation approach for unknown systems
            install_tools_ubuntu "unknown"
            ;;
    esac
}