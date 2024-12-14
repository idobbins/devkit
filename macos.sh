#!/bin/bash
set -euo pipefail

if [ "$(uname)" != "Darwin" ]; then
    echo "Error: This script is only for macOS systems"
    exit 1
fi

NIX_BASE_DIR="/opt/nixenv"
CONFIG_DIR="$NIX_BASE_DIR/config"

echo "Starting system bootstrap..."

# Ensure base directories exist with proper permissions
sudo mkdir -p "$NIX_BASE_DIR"
sudo chown $(whoami) "$NIX_BASE_DIR"
mkdir -p "$CONFIG_DIR"

# Install Nix normally first
if ! command -v nix &> /dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --determinate
    . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
    
    # Now move the Nix store to our preferred location
    sudo mv /nix "$NIX_BASE_DIR/"
    sudo ln -s "$NIX_BASE_DIR/nix" /nix
fi

# Clone config repo
cd "$CONFIG_DIR" && rm -rf env
git clone https://github.com/idobbins/env.git env

# Symlink flake configuration
cp "$CONFIG_DIR/env/nix/macos-flake.nix" "$CONFIG_DIR/flake.nix"

# Build and activate configuration
cd "$CONFIG_DIR"
nix profile install .

echo "Bootstrap complete! Please restart your terminal."
