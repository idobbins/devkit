#!/bin/bash
set -euo pipefail

# Check if running on macOS
if [ "$(uname)" != "Darwin" ]; then
    echo "Error: This script is only for macOS systems"
    exit 1
fi

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

echo "Starting macOS system bootstrap..."

# Check for Xcode Command Line Tools
if ! command_exists gcc; then
    echo "Installing Xcode Command Line Tools..."
    sudo xcode-select --install
fi

# Install Nix if not already installed
if ! command_exists nix; then
    echo "Installing Nix..."
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --determinate
    . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi

# Set up directories relative to HOME
cd "$HOME"
mkdir -p .config/{nix,nvim}

# Clone or update repository
if [ ! -d ".config/env" ]; then
    echo "Cloning configuration repository..."
    git clone https://github.com/idobbins/env.git .config/env
else
    echo "Updating configuration repository..."
    cd .config/env
    git pull
fi

# Create symlinks using relative paths
echo "Creating symlinks..."
cd "$HOME/.config"

# Neovim config symlink
ln -sfn env/nvim/init.lua nvim/init.lua

# Nix config symlink 
ln -sfn env/macos-flake.nix nix/flake.nix

# Build and activate configuration
echo "Building and activating configuration..."
cd nix
nix build --impure
home-manager switch --flake .#idobbins --impure

echo "Bootstrap complete! Your macOS environment has been configured."
echo "Configuration files are in: ~/.config/env"
echo "Please restart your terminal for all changes to take effect."
