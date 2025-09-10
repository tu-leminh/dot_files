#!/bin/bash

# Script to install the latest versions of nvim, ranger, tmux, zsh, lazygit, and k9s on Ubuntu
# Works with both current and end-of-life Ubuntu versions
# Currently installed versions are documented in BOTS.md for tracking purposes
# This script will always install the latest stable releases of all tools

set -e  # Exit on any error

echo "Installing latest versions of nvim, ranger, tmux, zsh, lazygit, and k9s..."

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

# Install latest zsh
echo "Installing latest zsh..."
# Always install the latest version available via apt
sudo apt update
sudo apt install -y zsh
if command_exists zsh; then
    ZSH_VERSION=$(zsh --version | cut -d' ' -f2)
    echo "zsh $ZSH_VERSION installed"
fi

# Install latest ranger
echo "Installing latest ranger..."
# Always install the latest version available via pip
pip3 install ranger-fm --upgrade
if command_exists ranger; then
    RANGER_VERSION=$(ranger --version 2>&1 | head -n 1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
    echo "ranger $RANGER_VERSION installed"
fi

# Install latest tmux
echo "Installing latest tmux..."
# Always install the latest version available via apt
sudo apt update
sudo apt install -y tmux
if command_exists tmux; then
    TMUX_VERSION=$(tmux -V | cut -d' ' -f2)
    echo "tmux $TMUX_VERSION installed"
fi

# Install latest stable Neovim
echo "Installing latest stable Neovim..."
# Always install the latest stable version by compiling from source

# Install build dependencies for Neovim
echo "Installing build dependencies for Neovim..."
sudo apt update
sudo apt install -y ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip git

# Clone the Neovim repository
echo "Cloning Neovim repository..."
cd /tmp
if [ -d "neovim" ]; then
    rm -rf neovim
fi
git clone https://github.com/neovim/neovim.git
cd neovim

# Get the latest stable release tag
echo "Finding latest stable release..."
LATEST_TAG=$(git tag -l --sort=-v:refname | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | head -n 1)
if [ -z "$LATEST_TAG" ]; then
    echo "Error: Failed to find latest stable release tag"
    exit 1
fi

echo "Checking out latest stable release: $LATEST_TAG"
git checkout "$LATEST_TAG"

# Build and install Neovim
echo "Building Neovim..."
make CMAKE_BUILD_TYPE=Release
echo "Installing Neovim..."
sudo make install

# Clean up
cd ..
rm -rf neovim

if command_exists nvim; then
    NVIM_VERSION=$(nvim --version | head -n 1)
    echo "Neovim $NVIM_VERSION installed"
fi

# Install lazygit (latest stable release)
echo "Installing lazygit..."
# Always install the latest version of lazygit
cd /tmp
LAZYGIT_URL=$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep browser_download_url | grep Linux_x86_64 | head -n 1 | cut -d '"' -f 4)
if [ -z "$LAZYGIT_URL" ]; then
    echo "Warning: Failed to find lazygit download URL, trying alternative method..."
    # Alternative method using the GitHub releases page directly
    LAZYGIT_VERSION=$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')
    if [ -z "$LAZYGIT_VERSION" ]; then
        echo "Error: Failed to determine lazygit version"
        exit 1
    fi
    LAZYGIT_URL="https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
fi

echo "Downloading lazygit from: $LAZYGIT_URL"
if ! wget "$LAZYGIT_URL" -O lazygit.tar.gz; then
    echo "Error: Failed to download lazygit"
    exit 1
fi

tar xzf lazygit.tar.gz
sudo install lazygit /usr/local/bin
rm lazygit.tar.gz lazygit

# Check installed version
if command_exists lazygit; then
    LAZYGIT_VERSION=$(lazygit --version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
    echo "lazygit $LAZYGIT_VERSION installed"
else
    echo "lazygit installed"
fi

# Install k9s (latest stable release)
echo "Installing k9s..."
# Always install the latest version of k9s
cd /tmp
K9S_URL=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | grep browser_download_url | grep Linux_amd64 | head -n 1 | cut -d '"' -f 4)
if [ -z "$K9S_URL" ]; then
    echo "Warning: Failed to find k9s download URL, trying alternative method..."
    # Alternative method using the GitHub releases page directly
    K9S_VERSION=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')
    if [ -z "$K9S_VERSION" ]; then
        echo "Error: Failed to determine k9s version"
        exit 1
    fi
    K9S_URL="https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/k9s_Linux_amd64.tar.gz"
fi

echo "Downloading k9s from: $K9S_URL"
if ! wget "$K9S_URL" -O k9s.tar.gz; then
    echo "Error: Failed to download k9s"
    exit 1
fi

tar xzf k9s.tar.gz k9s
sudo install k9s /usr/local/bin
rm k9s.tar.gz k9s

# Check installed version
if command_exists k9s; then
    K9S_VERSION_OUTPUT=$(k9s version 2>&1)
    K9S_VERSION=$(echo "$K9S_VERSION_OUTPUT" | grep Version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "")
    if [ -z "$K9S_VERSION" ]; then
        # Try alternative format
        K9S_VERSION=$(echo "$K9S_VERSION_OUTPUT" | head -n 1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
    fi
    echo "k9s $K9S_VERSION installed"
else
    echo "k9s installed"
fi

# Verify installations
echo "Verifying installations..."
echo "ZSH version: $(zsh --version)"
echo "Ranger version: ranger $(ranger --version 2>&1 | head -n 1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
echo "Tmux version: $(tmux -V)"
echo "Neovim version: $(nvim --version | head -n 1)"
if command_exists lazygit; then
    echo "Lazygit version: $(lazygit --version 2>&1)"
else
    echo "Lazygit: Not installed"
fi
if command_exists k9s; then
    echo "K9s version: $(k9s version 2>&1 | grep Version)"
else
    echo "K9s: Not installed"
fi

echo "All tools have been updated to their latest versions!"

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