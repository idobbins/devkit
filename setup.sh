#!/usr/bin/env bash
set -Eeuo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_SUFFIX="bak.$(date +%Y%m%d%H%M%S)"
ASSUME_YES=0
DO_UPGRADE=1
DO_PACKAGES=1
DO_SSH_KEY=1
CHANGE_SHELL=0

usage() {
  cat <<'EOF'
Usage: ./setup.sh [options]

Idempotent dev-box bootstrap for macOS and Ubuntu/Debian.

Options:
  -y, --yes          Non-interactive mode where possible.
  --no-upgrade       Skip OS package upgrades.
  --no-packages      Skip package manager installs.
  --no-ssh-key       Skip idempotent ~/.ssh/id_ed25519 generation.
  --change-shell     Attempt to make zsh the login shell.
  -h, --help         Show this help.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -y|--yes) ASSUME_YES=1; shift ;;
    --no-upgrade) DO_UPGRADE=0; shift ;;
    --no-packages) DO_PACKAGES=0; shift ;;
    --no-ssh-key) DO_SSH_KEY=0; shift ;;
    --change-shell) CHANGE_SHELL=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done

log() { printf '\n==> %s\n' "$*"; }
warn() { printf 'WARN: %s\n' "$*" >&2; }

as_root() {
  if [[ ${EUID:-$(id -u)} -eq 0 ]]; then
    "$@"
  else
    sudo "$@"
  fi
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1
}

confirm() {
  if [[ "$ASSUME_YES" -eq 1 ]]; then
    return 0
  fi
  read -r -p "$1 [y/N] " reply
  [[ "$reply" =~ ^[Yy]$ ]]
}

apt_install_list() {
  grep -Ev '^\s*(#|$)' "$DOTFILES_DIR/packages/apt.txt"
}

install_homebrew() {
  if [[ "$(uname -s)" != "Darwin" ]]; then
    return 0
  fi

  if ! xcode-select -p >/dev/null 2>&1; then
    log "Installing Xcode Command Line Tools"
    xcode-select --install || true
    echo "Re-run setup after Xcode Command Line Tools finish installing."
    exit 1
  fi

  if ! need_cmd brew; then
    log "Installing Homebrew"
    if [[ "$ASSUME_YES" -eq 1 ]]; then
      NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
  fi

  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi

  log "Updating Homebrew"
  brew update
  if [[ "$DO_UPGRADE" -eq 1 ]]; then
    log "Upgrading Homebrew packages"
    brew upgrade || true
  fi

  log "Installing Homebrew bundle"
  brew bundle --file="$DOTFILES_DIR/Brewfile"
}

install_debian_packages() {
  if [[ ! -r /etc/os-release ]]; then
    return 1
  fi
  # shellcheck disable=SC1091
  . /etc/os-release
  case "${ID:-}" in
    ubuntu|debian) ;;
    *)
      case "${ID_LIKE:-}" in
        *debian*) ;;
        *) return 1 ;;
      esac
      ;;
  esac

  export DEBIAN_FRONTEND=noninteractive
  log "Updating apt package index"
  as_root apt-get update

  if [[ "$DO_UPGRADE" -eq 1 ]]; then
    log "Upgrading apt packages"
    as_root apt-get -y upgrade
  fi

  log "Installing apt packages"
  while read -r package; do
    [[ -z "$package" ]] && continue
    if ! as_root apt-get install -y "$package"; then
      warn "Could not install apt package: $package"
    fi
  done < <(apt_install_list)

  install_github_cli_debian
  ensure_fd_debian
}

install_github_cli_debian() {
  if need_cmd gh; then
    return 0
  fi

  log "Installing GitHub CLI apt repository"
  as_root mkdir -p /etc/apt/keyrings
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | as_root tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null
  as_root chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" |
    as_root tee /etc/apt/sources.list.d/github-cli.list >/dev/null
  as_root apt-get update
  as_root apt-get install -y gh
}

ensure_fd_debian() {
  mkdir -p "$HOME/.local/bin"
  if ! need_cmd fd && need_cmd fdfind; then
    ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
  fi
  if ! need_cmd bat && need_cmd batcat; then
    ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
  fi
}

version_ge() {
  # Returns true if $1 >= $2.
  printf '%s\n%s\n' "$2" "$1" | sort -V -C
}

ensure_modern_neovim_linux() {
  if [[ "$(uname -s)" != "Linux" ]]; then
    return 0
  fi

  local current=""
  if need_cmd nvim; then
    current="$(nvim --version | awk 'NR==1 {gsub(/^v/, "", $2); print $2}')"
  fi

  if [[ -n "$current" ]] && version_ge "$current" "0.11.0"; then
    return 0
  fi

  local arch asset url tmpdir dest
  arch="$(uname -m)"
  case "$arch" in
    x86_64|amd64) asset="nvim-linux-x86_64.tar.gz"; dest="nvim-linux-x86_64" ;;
    aarch64|arm64) asset="nvim-linux-arm64.tar.gz"; dest="nvim-linux-arm64" ;;
    *) warn "Unsupported architecture for Neovim binary: $arch"; return 0 ;;
  esac

  log "Installing latest Neovim to ~/.local/opt/nvim"
  mkdir -p "$HOME/.local/bin" "$HOME/.local/opt"
  tmpdir="$(mktemp -d)"
  url="https://github.com/neovim/neovim/releases/latest/download/$asset"
  curl -fL "$url" -o "$tmpdir/$asset"
  tar -xzf "$tmpdir/$asset" -C "$tmpdir"
  rm -rf "$HOME/.local/opt/nvim"
  mv "$tmpdir/$dest" "$HOME/.local/opt/nvim"
  ln -sf "$HOME/.local/opt/nvim/bin/nvim" "$HOME/.local/bin/nvim"
  rm -rf "$tmpdir"
}

install_nvm_and_node() {
  export NVM_DIR="$HOME/.nvm"
  mkdir -p "$NVM_DIR"

  if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
    log "Installing nvm"
    curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
  fi

  # shellcheck disable=SC1091
  source "$NVM_DIR/nvm.sh"

  log "Installing/updating Node LTS via nvm"
  nvm install --lts
  nvm alias default 'lts/*'
  nvm use default >/dev/null

  log "Enabling corepack"
  corepack enable || true
  corepack prepare pnpm@latest --activate || true
}

install_npm_globals() {
  [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
  need_cmd npm || return 0

  log "Installing/updating global npm CLIs"
  while read -r command package; do
    [[ -z "${command:-}" || "${command:0:1}" == "#" ]] && continue
    npm install -g "$package"
  done < "$DOTFILES_DIR/packages/npm-global.txt"
}

install_uv() {
  if need_cmd uv; then
    return 0
  fi
  log "Installing uv"
  curl -LsSf https://astral.sh/uv/install.sh | sh
}

install_rustup() {
  if need_cmd rustup || need_cmd cargo; then
    return 0
  fi
  log "Installing rustup"
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
}

install_bun() {
  if need_cmd bun; then
    return 0
  fi
  log "Installing bun"
  curl -fsSL https://bun.sh/install | bash
}

install_deno() {
  if need_cmd deno; then
    return 0
  fi
  log "Installing deno"
  curl -fsSL https://deno.land/install.sh | sh
}

init_submodules() {
  if [[ -f "$DOTFILES_DIR/.gitmodules" ]]; then
    log "Initializing/updating git submodules"
    git -C "$DOTFILES_DIR" submodule update --init --recursive
  fi
}

backup_path_if_needed() {
  local path="$1"
  local resolved=""

  [[ -e "$path" || -L "$path" ]] || return 0

  if [[ -L "$path" ]]; then
    if need_cmd python3; then
      resolved="$(python3 -c 'import os,sys; print(os.path.realpath(sys.argv[1]))' "$path")"
    else
      resolved="$(readlink "$path")"
      [[ "$resolved" != /* ]] && resolved="$(dirname "$path")/$resolved"
    fi
    case "$resolved" in
      "$DOTFILES_DIR"/*) return 0 ;;
    esac
  fi

  log "Backing up $path to $path.$BACKUP_SUFFIX"
  mv "$path" "$path.$BACKUP_SUFFIX"
}

prepare_ssh() {
  log "Preparing SSH directory"
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"

  if [[ -f "$HOME/.ssh/config" && ! -L "$HOME/.ssh/config" ]]; then
    if [[ ! -e "$HOME/.ssh/config.local" ]]; then
      log "Moving existing ~/.ssh/config to ~/.ssh/config.local"
      mv "$HOME/.ssh/config" "$HOME/.ssh/config.local"
    else
      backup_path_if_needed "$HOME/.ssh/config"
    fi
  fi

  touch "$HOME/.ssh/config.local"
  chmod 600 "$HOME/.ssh/config.local"

  if [[ "$DO_SSH_KEY" -eq 1 ]]; then
    ensure_ssh_key
  fi
}

ensure_ssh_key() {
  local key="$HOME/.ssh/id_ed25519"
  if [[ -f "$key" ]]; then
    log "SSH key already exists: $key"
  else
    log "Generating SSH key: $key"
    ssh-keygen -t ed25519 -C "$(whoami)@$(hostname)-$(date +%Y%m%d)" -f "$key" -N ""
  fi
  chmod 600 "$key" 2>/dev/null || true
  chmod 644 "$key.pub" 2>/dev/null || true
}

remove_repo_symlink() {
  local path="$1"
  local resolved=""
  [[ -L "$path" ]] || return 0
  if need_cmd python3; then
    resolved="$(python3 -c 'import os,sys; print(os.path.realpath(sys.argv[1]))' "$path")"
  else
    resolved="$(readlink "$path")"
  fi
  case "$resolved" in
    "$DOTFILES_DIR"/*)
      log "Removing stale repo symlink $path"
      rm "$path"
      ;;
  esac
}

stow_dotfiles() {
  log "Creating symlinks with GNU Stow"
  mkdir -p "$HOME/.config" "$HOME/.local/bin" "$HOME/.oh-my-zsh/custom/plugins"

  # Clean up links from older versions of this repo that are no longer managed.
  remove_repo_symlink "$HOME/.gitignore"
  remove_repo_symlink "$HOME/.gitconfig-fundlaunch"

  backup_path_if_needed "$HOME/.zshrc"
  backup_path_if_needed "$HOME/.gitconfig"
  backup_path_if_needed "$HOME/.config/nvim"
  backup_path_if_needed "$HOME/.config/git/ignore"
  backup_path_if_needed "$HOME/.local/bin/tunnel"

  for plugin in zsh-autosuggestions zsh-syntax-highlighting zsh-bat zsh-nvm you-should-use dotfiles; do
    backup_path_if_needed "$HOME/.oh-my-zsh/custom/plugins/$plugin"
  done

  (cd "$DOTFILES_DIR" && stow --restow --target="$HOME" .)
}

maybe_change_shell() {
  [[ "$CHANGE_SHELL" -eq 1 ]] || return 0
  need_cmd zsh || return 0

  local zsh_path current_shell
  zsh_path="$(command -v zsh)"
  current_shell="${SHELL:-}"

  if [[ "$current_shell" == "$zsh_path" ]]; then
    log "Login shell already zsh"
    return 0
  fi

  if ! grep -qxF "$zsh_path" /etc/shells 2>/dev/null; then
    echo "$zsh_path" | as_root tee -a /etc/shells >/dev/null
  fi

  log "Changing login shell to $zsh_path"
  chsh -s "$zsh_path" "$USER" || warn "Could not change shell automatically"
}

main() {
  log "Setting up dotfiles from $DOTFILES_DIR"

  if [[ "$DO_PACKAGES" -eq 1 ]]; then
    case "$(uname -s)" in
      Darwin) install_homebrew ;;
      Linux)
        if ! install_debian_packages; then
          warn "Unsupported Linux distro. Skipping OS package installation."
        fi
        ensure_modern_neovim_linux
        ;;
      *) warn "Unsupported OS: $(uname -s). Skipping OS package installation." ;;
    esac

    install_uv
    install_rustup
    install_bun
    install_deno
    install_nvm_and_node
    install_npm_globals
  fi

  init_submodules
  prepare_ssh
  stow_dotfiles
  maybe_change_shell

  log "Done"
  echo "Restart your shell or run: source ~/.zshrc"
  echo "SSH public key:"
  [[ -f "$HOME/.ssh/id_ed25519.pub" ]] && sed 's/^/  /' "$HOME/.ssh/id_ed25519.pub"
  echo ""
  echo "Next auth steps as needed: gh auth login; pi /login; claude login; codex login"
}

main "$@"
