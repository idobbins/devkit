# Dotfiles management commands

DOTFILES_DIR="$HOME/.dotfiles"

# Dump brew packages to Brewfile
dfbrew() {
  echo "==> Updating Brewfile..."
  brew bundle dump --file="$DOTFILES_DIR/Brewfile" --force
  echo "==> Done. Review changes with: dfstatus"
}

# Refresh stow symlinks (unstow + restow)
dfstow() {
  echo "==> Refreshing stow symlinks..."
  cd "$DOTFILES_DIR" && stow -t ~ -D . && stow -t ~ .
  echo "==> Done."
}

# Show dotfiles git status
dfstatus() {
  cd "$DOTFILES_DIR" && git status
}

# Full sync: pull + update submodules + refresh stow
dfsync() {
  echo "==> Pulling latest changes..."
  cd "$DOTFILES_DIR" && git pull --recurse-submodules
  echo "==> Refreshing stow symlinks..."
  dfstow
  echo "==> Sync complete."
}

# Add, commit, and push dotfiles changes
dfpush() {
  cd "$DOTFILES_DIR"
  git add -A
  git status
  echo ""
  read "msg?Commit message: "
  git commit -m "$msg" && git push
}
