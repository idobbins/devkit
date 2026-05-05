#!/usr/bin/env bash
set -euo pipefail

REPO_URL="${REPO_URL:-https://github.com/idobbins/devkit.git}"
DEST="${DEVKIT_HOME:-$HOME/.devkit}"
NO_UPGRADE=0
INSTALL_TAILSCALE="${INSTALL_TAILSCALE:-}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo) REPO_URL="$2"; shift 2 ;;
    --dest) DEST="$2"; shift 2 ;;
    --no-upgrade) NO_UPGRADE=1; shift ;;
    --tailscale) INSTALL_TAILSCALE=1; shift ;;
    -h|--help) echo "Usage: bootstrap.sh [--repo URL] [--dest PATH] [--no-upgrade] [--tailscale]"; exit 0 ;;
    *) echo "Unknown option: $1" >&2; exit 2 ;;
  esac
done

os="$(uname -s)"

if [[ "$os" == "Linux" ]] && command -v apt-get >/dev/null 2>&1; then
  sudo apt-get update
  [[ "$NO_UPGRADE" == 1 ]] || sudo apt-get -y upgrade
  sudo apt-get install -y curl git sudo xz-utils ca-certificates
fi

if ! command -v nix >/dev/null 2>&1; then
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --determinate --no-confirm
  # shellcheck disable=SC1091
  [[ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]] && source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

if [[ "$os" == "Linux" && ( -n "$INSTALL_TAILSCALE" || -n "${TAILSCALE_AUTHKEY:-}" ) ]]; then
  if ! command -v tailscale >/dev/null 2>&1; then
    curl -fsSL https://tailscale.com/install.sh | sh
  fi
  if [[ -n "${TAILSCALE_AUTHKEY:-}" ]]; then
    sudo tailscale up --ssh --auth-key "$TAILSCALE_AUTHKEY"
  fi
fi

if [[ -d "$DEST/.git" ]]; then
  git -C "$DEST" pull --ff-only
else
  git clone "$REPO_URL" "$DEST"
fi

if [[ "$os" == "Darwin" ]]; then
  nix_bin="$(command -v nix)"
  if [[ ${EUID:-$(id -u)} -eq 0 ]]; then
    "$nix_bin" run nix-darwin -- switch --flake "$DEST#macos" --impure
  else
    sudo env HOME="$HOME" USER="$USER" DEVKIT_HOME="$DEST" "$nix_bin" run nix-darwin -- switch --flake "$DEST#macos" --impure
  fi
else
  nix run home-manager -- switch --flake "$DEST#linux" --impure
fi

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
if [[ ! -f "$HOME/.ssh/id_ed25519" ]]; then
  ssh-keygen -t ed25519 -N "" -f "$HOME/.ssh/id_ed25519"
fi

printf '\nNext auth steps:\n  gh auth login\n  pi /login\n  claude login\n  codex login\n\nDaily devkit commands:\n  devkit update   # pull and apply this config\n  devkit edit     # edit ~/.devkit\n  work notoil     # jump to ~/dev/i7/notoil when using zsh\n\nSSH public key:\n'
cat "$HOME/.ssh/id_ed25519.pub"

if command -v tailscale >/dev/null 2>&1; then
  printf '\nTailscale status:\n'
  tailscale status || true
fi
