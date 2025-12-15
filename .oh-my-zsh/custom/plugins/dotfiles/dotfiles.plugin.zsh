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
  pushd -q "$DOTFILES_DIR"
  echo "==> Refreshing stow symlinks..."
  stow -t ~ -D . && stow -t ~ .
  echo "==> Done."
  popd -q
}

# Show dotfiles git status
dfstatus() {
  pushd -q "$DOTFILES_DIR"
  git status
  popd -q
}

# Full sync: pull + update submodules + refresh stow
dfsync() {
  pushd -q "$DOTFILES_DIR"
  echo "==> Pulling latest changes..."
  git pull --recurse-submodules
  echo "==> Refreshing stow symlinks..."
  stow -t ~ -D . && stow -t ~ .
  echo "==> Sync complete."
  popd -q
}

# Add, commit, and push dotfiles changes
dfpush() {
  pushd -q "$DOTFILES_DIR"
  git add -A
  git status
  echo ""
  read "msg?Commit message: "
  git commit -m "$msg" && git push
  popd -q
}
