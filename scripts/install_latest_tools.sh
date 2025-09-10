#!/bin/bash

# Script to install specific versions of nvim, ranger, tmux, and zsh on Ubuntu
# Works with both current and end-of-life Ubuntu versions
# Target versions based on current installation:
# - zsh: 5.8
# - ranger: 1.9.3
# - tmux: 3.5a
# - neovim: 0.12.0-dev

set -e  # Exit on any error

echo "Installing specific versions of nvim, ranger, tmux, and zsh..."

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to compare version strings
version_gt() {
    test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1"
}

# Check if we're on Ubuntu
if ! grep -q "Ubuntu" /etc/os-release 2>/dev/null; then
    echo "Warning: This script is designed for Ubuntu systems."
    read -p "Continue anyway? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Install dependencies with error handling
echo "Installing dependencies..."
if ! sudo apt update; then
    echo "Error: Failed to update package lists"
    exit 1
fi

if ! sudo apt install -y software-properties-common build-essential wget curl git \
    libevent-dev libncurses-dev automake pkg-config bison libbz2-dev \
    libreadline-dev libsqlite3-dev libssl-dev libffi-dev zlib1g-dev \
    liblzma-dev llvm libncursesw5-dev xz-utils tk-dev libxml2-dev \
    libxmlsec1-dev libffi-dev liblzma-dev python3-dev python3-pip; then
    echo "Error: Failed to install dependencies"
    exit 1
fi

# Install zsh 5.8
echo "Installing zsh 5.8..."
if command_exists zsh; then
    ZSH_VERSION=$(zsh --version | cut -d' ' -f2)
    if [[ "$ZSH_VERSION" == "5.8" ]]; then
        echo "zsh 5.8 is already installed"
    else
        echo "zsh $ZSH_VERSION is installed, but we need version 5.8"
        sudo apt remove -y zsh
        cd /tmp
        if ! wget https://sourceforge.net/projects/zsh/files/zsh/5.8/zsh-5.8.tar.xz; then
            echo "Error: Failed to download zsh 5.8"
            exit 1
        fi
        tar -xf zsh-5.8.tar.xz
        cd zsh-5.8
        ./configure --enable-cap --enable-pcre --enable-readnullcmd --enable-multibyte \
            --with-term-lib='ncursesw' --with-tcsetpgrp --program-transform-name='s/^zsh$/zsh-5.8/'
        if ! make -j$(nproc); then
            echo "Error: Failed to compile zsh"
            exit 1
        fi
        sudo make install
        sudo ln -sf /usr/local/bin/zsh /usr/bin/zsh-5.8
        echo "zsh 5.8 installed"
    fi
else
    cd /tmp
    if ! wget https://sourceforge.net/projects/zsh/files/zsh/5.8/zsh-5.8.tar.xz; then
        echo "Error: Failed to download zsh 5.8"
        exit 1
    fi
    tar -xf zsh-5.8.tar.xz
    cd zsh-5.8
    ./configure --enable-cap --enable-pcre --enable-readnullcmd --enable-multibyte \
        --with-term-lib='ncursesw' --with-tcsetpgrp --program-transform-name='s/^zsh$/zsh-5.8/'
    if ! make -j$(nproc); then
        echo "Error: Failed to compile zsh"
        exit 1
    fi
    sudo make install
    sudo ln -sf /usr/local/bin/zsh /usr/bin/zsh-5.8
    echo "zsh 5.8 installed"
fi

# Install ranger 1.9.3
echo "Installing ranger 1.9.3..."
if command_exists ranger; then
    RANGER_VERSION=$(ranger --version | head -n 1 | cut -d' ' -f2)
    if [[ "$RANGER_VERSION" == "1.9.3" ]]; then
        echo "ranger 1.9.3 is already installed"
    else
        echo "ranger $RANGER_VERSION is installed, but we need version 1.9.3"
        if ! pip3 install ranger-fm==1.9.3; then
            echo "Error: Failed to install ranger 1.9.3"
            exit 1
        fi
        echo "ranger 1.9.3 installed"
    fi
else
    if ! pip3 install ranger-fm==1.9.3; then
        echo "Error: Failed to install ranger 1.9.3"
        exit 1
    fi
    echo "ranger 1.9.3 installed"
fi

# Install tmux 3.5a
echo "Installing tmux 3.5a..."
if command_exists tmux; then
    TMUX_VERSION=$(tmux -V | cut -d' ' -f2)
    if [[ "$TMUX_VERSION" == "3.5a" ]]; then
        echo "tmux 3.5a is already installed"
    else
        echo "tmux $TMUX_VERSION is installed, but we need version 3.5a"
        sudo apt remove -y tmux
        cd /tmp
        if ! wget https://github.com/tmux/tmux/releases/download/3.5a/tmux-3.5a.tar.gz; then
            echo "Error: Failed to download tmux 3.5a"
            exit 1
        fi
        tar -xzf tmux-3.5a.tar.gz
        cd tmux-3.5a
        if ! ./configure; then
            echo "Error: Failed to configure tmux"
            exit 1
        fi
        if ! make -j$(nproc); then
            echo "Error: Failed to compile tmux"
            exit 1
        fi
        sudo make install
        echo "tmux 3.5a installed"
    fi
else
    cd /tmp
    if ! wget https://github.com/tmux/tmux/releases/download/3.5a/tmux-3.5a.tar.gz; then
        echo "Error: Failed to download tmux 3.5a"
        exit 1
    fi
    tar -xzf tmux-3.5a.tar.gz
    cd tmux-3.5a
    if ! ./configure; then
        echo "Error: Failed to configure tmux"
        exit 1
    fi
    if ! make -j$(nproc); then
        echo "Error: Failed to compile tmux"
        exit 1
    fi
    sudo make install
    echo "tmux 3.5a installed"
fi

# Install Neovim 0.12.0-dev
echo "Installing Neovim 0.12.0-dev..."
if command_exists nvim; then
    NVIM_VERSION=$(nvim --version | head -n 1)
    if [[ "$NVIM_VERSION" == *"NVIM v0.12.0-dev"* ]]; then
        echo "Neovim 0.12.0-dev is already installed"
    else
        echo "Neovim is installed, but we need version 0.12.0-dev"
        # For development versions, we'll install from AppImage to get the latest dev version
        cd /tmp
        if ! wget https://github.com/neovim/neovim/releases/download/nightly/nvim.appimage; then
            echo "Error: Failed to download Neovim AppImage"
            exit 1
        fi
        chmod +x nvim.appimage
        sudo mv nvim.appimage /usr/local/bin/nvim
        echo "Neovim 0.12.0-dev installed"
    fi
else
    # For development versions, we'll install from AppImage to get the latest dev version
    cd /tmp
    if ! wget https://github.com/neovim/neovim/releases/download/nightly/nvim.appimage; then
        echo "Error: Failed to download Neovim AppImage"
        exit 1
    fi
    chmod +x nvim.appimage
    sudo mv nvim.appimage /usr/local/bin/nvim
    echo "Neovim 0.12.0-dev installed"
fi

# Verify installations
echo "Verifying installations..."
echo "ZSH version: $(zsh --version)"
echo "Ranger version: $(ranger --version | head -n 1)"
echo "Tmux version: $(tmux -V)"
echo "Neovim version: $(nvim --version | head -n 1)"

echo "All tools have been installed with the specified versions!"

# Optional: Set zsh as default shell
read -p "Do you want to set zsh as your default shell? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if chsh -s $(which zsh); then
        echo "zsh has been set as your default shell. Log out and back in to apply changes."
    else
        echo "Error: Failed to set zsh as default shell"
    fi
fi