#!/bin/bash

# Script to install specific versions of nvim, ranger, tmux, and zsh on Ubuntu
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

# Install dependencies
echo "Installing dependencies..."
sudo apt update
sudo apt install -y software-properties-common build-essential wget curl git \
    libevent-dev libncurses-dev automake pkg-config bison libbz2-dev \
    libreadline-dev libsqlite3-dev libssl-dev libffi-dev zlib1g-dev \
    liblzma-dev llvm libncursesw5-dev xz-utils tk-dev libxml2-dev \
    libxmlsec1-dev libffi-dev liblzma-dev python3-dev python3-pip

# Install zsh 5.8
echo "Installing zsh 5.8..."
if command_exists zsh && [[ "$(zsh --version)" == *"zsh 5.8"* ]]; then
    echo "zsh 5.8 is already installed"
else
    sudo apt remove -y zsh
    cd /tmp
    wget https://sourceforge.net/projects/zsh/files/zsh/5.8/zsh-5.8.tar.xz
    tar -xf zsh-5.8.tar.xz
    cd zsh-5.8
    ./configure --enable-cap --enable-pcre --enable-readnullcmd --enable-multibyte \
        --with-term-lib='ncursesw' --with-tcsetpgrp --program-transform-name='s/^zsh$/zsh-5.8/'
    make -j$(nproc)
    sudo make install
    sudo ln -sf /usr/local/bin/zsh /usr/bin/zsh-5.8
    echo "zsh 5.8 installed"
fi

# Install ranger 1.9.3
echo "Installing ranger 1.9.3..."
if command_exists ranger && [[ "$(ranger --version | head -n 1)" == *"ranger 1.9.3"* ]]; then
    echo "ranger 1.9.3 is already installed"
else
    pip3 install ranger-fm==1.9.3
    echo "ranger 1.9.3 installed"
fi

# Install tmux 3.5a
echo "Installing tmux 3.5a..."
if command_exists tmux && [[ "$(tmux -V)" == *"tmux 3.5a"* ]]; then
    echo "tmux 3.5a is already installed"
else
    sudo apt remove -y tmux
    cd /tmp
    wget https://github.com/tmux/tmux/releases/download/3.5a/tmux-3.5a.tar.gz
    tar -xzf tmux-3.5a.tar.gz
    cd tmux-3.5a
    ./configure
    make -j$(nproc)
    sudo make install
    echo "tmux 3.5a installed"
fi

# Install Neovim 0.12.0-dev
echo "Installing Neovim 0.12.0-dev..."
if command_exists nvim && [[ "$(nvim --version | head -n 1)" == *"NVIM v0.12.0-dev"* ]]; then
    echo "Neovim 0.12.0-dev is already installed"
else
    # For development versions, we'll install from AppImage to get the latest dev version
    cd /tmp
    wget https://github.com/neovim/neovim/releases/download/nightly/nvim.appimage
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
    chsh -s $(which zsh)
    echo "zsh has been set as your default shell. Log out and back in to apply changes."
fi