#!/bin/bash
set -euo pipefail

echo "Installing Nix using Determinate Systems installer..."
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# Source nix
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

echo "Installing home-manager..."
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update

echo "Creating initial home-manager configuration..."
mkdir -p ~/.config/nix
mkdir -p ~/.config/home-manager

# Download flake.nix
curl -o ~/.config/home-manager/flake.nix https://raw.githubusercontent.com/YOUR_REPO/YOUR_PATH/flake.nix

# Initial home-manager switch
echo "Running initial home-manager switch..."
cd ~/.config/home-manager
nix run home-manager/master -- init --switch

# Shell will be set by home-manager

echo "Installation complete! Please restart your terminal."
