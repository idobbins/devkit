#!/bin/bash
set -euo pipefail

if [ "$(uname)" != "Darwin" ]; then
    echo "Error: This script is only for macOS systems"
    exit 1
fi

echo "Starting system bootstrap..."

# Install Nix if not present
if ! command -v nix &> /dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --determinate
    . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi

# Create config directory
mkdir -p "$HOME/.config/nix"

# Clone your repo (replace with your actual repo URL)
REPO_URL="https://github.com/idobbins/env.git"
REPO_DIR="$HOME/.config/env"

rm -rf "$REPO_DIR"
git clone "$REPO_URL" "$REPO_DIR"

# Create flake.nix symlink
cp "$REPO_DIR/nix/macos-flake.nix" "$HOME/.config/nix/flake.nix"

# Enable flakes and nix-command
mkdir -p "$HOME/.config/nix"
echo "experimental-features = nix-command flakes" > "$HOME/.config/nix/nix.conf"

# Build and activate configuration
cd "$HOME/.config/nix"
nix profile install .

echo "Bootstrap complete! Please restart your terminal."
