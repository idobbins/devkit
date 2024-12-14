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

# Set up directories
CONFIG_DIR="$HOME/.config"
ENV_DIR="$CONFIG_DIR/env"
NIX_DIR="$CONFIG_DIR/nix"
NVIM_DIR="$CONFIG_DIR/nvim"

# Create necessary directories
mkdir -p "$CONFIG_DIR" "$NIX_DIR" "$NVIM_DIR"

# Clone or update repository
if [ ! -d "$ENV_DIR" ]; then
    echo "Cloning configuration repository..."
    git clone https://github.com/idobbins/env.git "$ENV_DIR"
else
    echo "Updating configuration repository..."
    cd "$ENV_DIR"
    git pull
fi

# Create symlinks
echo "Creating symlinks..."
ln -sfn "$ENV_DIR/nix" "$NIX_DIR/profile"
ln -sfn "$ENV_DIR/nvim" "$NVIM_DIR/profile"

# Build and activate configuration
echo "Building and activating configuration..."
cd "$NIX_DIR"
nix build
home-manager switch --flake "$ENV_DIR/#idobbins"

echo "Bootstrap complete! Your macOS environment has been configured."
echo "Configuration files are at: $ENV_DIR"
echo "Please restart your terminal for all changes to take effect."
