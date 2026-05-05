# Devkit Dotfiles

Portable Nix-powered dev environment for macOS and Linux.

## Quick start

```bash
git clone https://github.com/idobbins/devkit ~/.devkit
~/.devkit/bootstrap.sh
```

Remote one-liner:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/idobbins/devkit/main/bootstrap.sh)"
```

With Tailscale auth on Ubuntu/Debian:

```bash
TAILSCALE_AUTHKEY=tskey-auth-... bash -c "$(curl -fsSL https://raw.githubusercontent.com/idobbins/devkit/main/bootstrap.sh)"
```

## What bootstrap does

- installs Determinate Nix if missing
- on Ubuntu/Debian, runs `apt-get update && apt-get -y upgrade` and installs bootstrap deps
- optionally installs/joins Tailscale when `TAILSCALE_AUTHKEY` is set or `--tailscale` is passed
- clones/pulls this repo
- applies the Nix flake:
  - macOS: `nix-darwin` target `#macos`
  - Linux: Home Manager target `#linux`
- creates `~/.ssh/id_ed25519` only if missing
- prints next auth steps and your SSH public key

Skip OS upgrades:

```bash
~/.devkit/bootstrap.sh --no-upgrade
```

## Managed by Nix

Core tools include Git/GitHub CLI, Neovim, ripgrep/fd/fzf, jq/yq, bat/eza, tmux, direnv, curl/wget/rsync, gnupg/openssh/autossh, cmake/make/pkg-config, uv, Node 24/pnpm, bun, deno, rustup, dotnet/opam/zig, AWS/SAM/gcloud/Databricks CLIs, PostgreSQL/MongoDB tools, and ffmpeg/yt-dlp. GUI apps are intentionally not managed here, and Homebrew is intentionally not used.

AI CLIs are installed through Nix/Home Manager:

- `pi`
- `claude`
- `codex`

## Daily commands

After bootstrap, use the `devkit` helper instead of remembering Nix commands:

```bash
devkit update        # git pull ~/.devkit, then apply the right macOS/Linux config
devkit apply         # apply current config
devkit edit          # open ~/.devkit in $EDITOR
devkit status        # show repo/platform status
devkit doctor        # check required tools and paths
devkit project-info  # inspect the current project
```

Short zsh aliases:

```bash
dku   # devkit update
dka   # devkit apply
dke   # devkit edit
dks   # devkit status
dkd   # devkit doctor
```

Jump to projects under `~/dev`:

```bash
work                 # cd ~/dev
work notoil          # cd ~/dev/i7/notoil if it exists, then show project info
work i7/notoil       # cd ~/dev/i7/notoil
```

## Local-only config

These remain outside the repo:

```txt
~/.zshrc.local
~/.gitconfig.local
~/.ssh/config.local
```

Use them for secrets, work identities, SSH aliases, tokens, and local paths.

## Tunneling remote apps

```bash
tunnel devbox 3000
tunnel devbox 3000 5173 8000
tunnel devbox 8080:3000
tunnel --keep devbox 3000
```

## Direct flake commands

Normally use `devkit apply`. If you need the raw commands:

```bash
home-manager switch --flake ~/.devkit#linux --impure
darwin-rebuild switch --flake ~/.devkit#macos --impure
```

Determinate owns Nix itself, so nix-darwin is configured with `nix.enable = false`.
