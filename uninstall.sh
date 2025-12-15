#!/bin/bash
set -e

echo "==> Removing dotfiles symlinks..."

cd ~/.dotfiles && stow -t ~ -D .

echo "==> Restoring backup files..."

for file in .zshrc .gitconfig .gitconfig-fundlaunch; do
    if [ -f "$HOME/$file.bak" ]; then
        echo "    Restoring ~/$file from ~/$file.bak"
        mv "$HOME/$file.bak" "$HOME/$file"
    fi
done

echo "==> Done! Dotfiles repo remains at ~/.dotfiles"
echo "    To fully remove: rm -rf ~/.dotfiles"
