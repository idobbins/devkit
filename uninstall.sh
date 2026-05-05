#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Removing dotfiles symlinks from $HOME"
(cd "$DOTFILES_DIR" && stow --delete --target="$HOME" .)

echo "==> Dotfiles repo remains at $DOTFILES_DIR"
echo "    Backups created by setup are left in place (*.bak.TIMESTAMP)."
