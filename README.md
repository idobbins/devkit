# Devkit Dotfiles

Portable Nix-powered dev environment for macOS, guest/non-NixOS Linux, and full NixOS machines.

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

- installs Determinate Nix if missing, except on NixOS where Nix is assumed to exist
- on Ubuntu/Debian, runs `apt-get update && apt-get -y upgrade` and installs bootstrap deps
- optionally installs/joins Tailscale on non-NixOS Linux when `TAILSCALE_AUTHKEY` is set or `--tailscale` is passed
- clones/pulls this repo
- applies the Nix flake:
  - macOS: `nix-darwin` target `#macos`
  - guest/non-NixOS Linux: Home Manager target `#linux`
  - NixOS: system target `#nixos`
- creates `~/.ssh/id_ed25519` only if missing
- prints next auth steps and your SSH public key

Skip OS upgrades:

```bash
~/.devkit/bootstrap.sh --no-upgrade
```

## Supported modes

- `#macos`: macOS through nix-darwin + Home Manager.
- `#linux`: non-NixOS Linux through standalone Home Manager.
- `#nixos`: full NixOS machines through `nixos-rebuild`.

Shared user tooling lives in `modules/home`. NixOS system services and users live in `modules/nixos`. Real NixOS hardware, bootloader, disks, filesystems, hostname, and host-specific networking should live under `hosts/machines/<name>/`; see `hosts/machines/example/`.

## Managed by Nix

Core tools include Git/GitHub CLI, Neovim, ripgrep/fd/fzf, jq/yq, bat/eza, tmux, direnv, curl/wget/rsync, gnupg/openssh, coreutils, and file. Language runtimes, cloud CLIs, databases, and media tools are intentionally left to project-local shells or local-only config. GUI apps are intentionally not managed here, and Homebrew is intentionally not used.

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
devkit pi-sync       # register ~/.devkit as a pi package
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

Manifest-driven tunnels:

```bash
tunnel fort --manifest .devkit/tunnels.json
tunnel fort --remote-manifest /home/ian/project/.devkit/tunnels.json
```

Manifest format:

```json
{
  "ports": {
    "frontend": 54003,
    "convex_backend": 54000
  },
  "urls": {
    "frontend": "http://localhost:54003"
  }
}
```

Only `ports` and `urls` are used by the tunnel tooling. Keep secrets in separate ignored files.

## Pi extensions

This repo is also a local pi package. To register it on a machine:

```bash
devkit pi-sync
```

Then restart pi or run `/reload`. The first extension adds:

```text
/tunnels
```

Run `/tunnels` from a project with `.devkit/tunnels.json` to print the client-side command, e.g.:

```bash
tunnel fort --remote-manifest /home/ian/project/.devkit/tunnels.json
```

## Direct flake commands

Normally use `devkit apply`. If you need the raw commands:

```bash
devkit apply
sudo nixos-rebuild switch --flake ~/.devkit#nixos
nix --option nix-path "" run home-manager -- switch --flake ~/.devkit#linux --impure
nix --option nix-path "" run nix-darwin -- switch --flake ~/.devkit#macos --impure
```

Determinate owns Nix itself, so nix-darwin is configured with `nix.enable = false`.
