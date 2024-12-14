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

# Install Nix 
if ! command -v nix &> /dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | \
    sh -s -- install --determinate --nix-root-dir "$NIX_BASE_DIR/nix"
    
    . "$NIX_BASE_DIR/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
fi

# Clone config repo
cd "$CONFIG_DIR" && rm -rf env
git clone https://github.com/idobbins/env.git env

# Symlink flake configuration
cp "$CONFIG_DIR/env/nix/macos-flake.nix" "$CONFIG_DIR/flake.nix"

# Build and activate configuration
cd "$CONFIG_DIR"
NIX_STATE_DIR="$NIX_BASE_DIR/nix/var/nix" nix profile install .

# Add environment setup to shell rc file
SHELL_RC="$HOME/.$(basename $SHELL)rc"
echo "source $NIX_BASE_DIR/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" >> "$SHELL_RC"

echo "Bootstrap complete! Please restart your terminal."
