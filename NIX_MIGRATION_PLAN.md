# Nix Dotfiles Migration Plan

Goal: make this repo a public, portable, one-command dev environment for macOS and Linux using Nix instead of rebuilding package/config management with shell scripts and Stow.

## Philosophy

- One baseline dev environment across machines.
- No work/personal/host-specific config multiplexing in the repo.
- OS-specific bootstrap is fine; config divergence should be minimal.
- Secrets, Git identities, SSH host aliases, tokens, and local paths stay outside the repo.
- Bootstrap should be idempotent and safe to re-run on fresh or existing machines.
- Nix owns packages/config; bootstrap only installs Nix and applies the flake.

## Target stack

### macOS

- Install Nix via Determinate Systems installer.
- Use `nix-darwin` for macOS system/user config.
- Use Home Manager for user config.
- Use `nix-homebrew`/Homebrew only for macOS apps/casks that are better installed outside nixpkgs.
- Important: Determinate owns Nix itself, so `nix-darwin` should not manage Nix.

```nix
nix.enable = false;
```

### Linux remote boxes

- Install Determinate Nix.
- Use Home Manager standalone.
- No NixOS requirement.
- Bootstrap may run `apt-get update` and `apt-get -y upgrade` first on Ubuntu/Debian.

### Future

- Add NixOS host configs later if useful.

## Proposed repo layout

```txt
.dotfiles/
  flake.nix
  flake.lock

  modules/
    home/
      default.nix
      packages.nix
      zsh.nix
      git.nix
      ssh.nix
      neovim.nix
      tunnel.nix
      ai.nix

    darwin/
      default.nix
      homebrew.nix

  hosts/
    macos.nix
    linux.nix

  bootstrap.sh
  README.md
```

## Flake inputs

Likely inputs:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };
}
```

## Bootstrap behavior

`bootstrap.sh` should be small and imperative only where unavoidable.

Responsibilities:

1. Detect OS.
2. On Ubuntu/Debian:
   - `sudo apt-get update`
   - `sudo apt-get -y upgrade`
   - install bootstrap deps: `curl git sudo xz-utils ca-certificates`
3. Install Determinate Nix if missing:

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
  | sh -s -- install --determinate --no-confirm
```

4. Optionally install/join Tailscale:
   - install Tailscale on Linux when requested or when `TAILSCALE_AUTHKEY` exists
   - run `sudo tailscale up --ssh --auth-key "$TAILSCALE_AUTHKEY"` when an auth key is provided
   - never store auth keys in the repo
5. Clone/pull this repo to `~/.dotfiles` or the eventual renamed path.
6. Apply the appropriate flake target:
   - macOS: `darwin-rebuild switch --flake ~/.dotfiles#macos`
   - Linux: `home-manager switch --flake ~/.dotfiles#linux`
7. Generate `~/.ssh/id_ed25519` only if missing.
8. Print next auth steps, SSH public key, and Tailscale status/hostname if available.

Use `--impure` if needed to support arbitrary usernames/homes cleanly.

## Baseline packages

Nix should own the main package set:

```txt
git
git-lfs
gh
neovim
ripgrep
fd
fzf
jq
yq
bat
eza
tree
tmux
direnv
curl
wget
rsync
unzip
gnupg
openssh
autossh
cmake
gnumake
pkg-config
uv
nodejs_24
pnpm
bun
deno
rustup
awscli2
postgresql_16
```

Prefer Nix-provided Node over `nvm` by default. Project-specific Node versions should eventually come from project flakes/direnv. Keep `nvm` only as an optional escape hatch if needed.

## AI CLIs

Desired commands:

```txt
pi
claude
codex
opencode
```

Implementation order:

1. Use nixpkgs packages where available.
2. Use Homebrew casks on macOS where they are the best-supported path.
3. Use a Home Manager activation step for fast-moving npm globals if needed.
4. Package missing tools properly later with Nix derivations.

Initial pragmatic npm global fallback candidates:

```txt
@mariozechner/pi-coding-agent
@anthropic-ai/claude-code
@openai/codex
```

## Neovim direction

Move from hand-managed Lazy config to `nixvim`.

Keep the editor lean:

- Telescope + fzf-native
- Treesitter
- LSP/Mason-equivalent support via Nix/nixvim
- `blink.cmp`
- GitHub dark theme
- minimal keybinds

Avoid reintroducing a large plugin pile unless missed.

## Shell direction

Use Home Manager to manage zsh directly.

Keep the shell fast:

- no Oh My Zsh startup path
- portable PATH setup
- history/completion
- lightweight git prompt
- minimal git aliases
- optional local file sourcing if appropriate

Local-only files remain untracked:

```txt
~/.zshrc.local
~/.gitconfig.local
~/.ssh/config.local
```

## Git direction

Universal repo config only:

- name if desired
- editor
- default branch
- safe defaults
- include `~/.gitconfig.local`

Emails, signing keys, and work-specific SSH commands stay local.

## Tailscale direction

Tailscale should be a first-class part of the remote dev-box story.

It simplifies remote access by providing:

- stable MagicDNS hostnames, e.g. `ssh ubuntu@devbox`
- private networking without exposing SSH to the public internet
- optional Tailscale SSH so per-box SSH key distribution is less important
- direct browser access to remote dev servers when apps bind to the Tailscale interface or `0.0.0.0`

### Install strategy

macOS:

- install the Tailscale app through Homebrew cask via nix-darwin/nix-homebrew
- user logs in through the app normally

Linux remote boxes:

- install Tailscale as part of bootstrap or host setup
- for non-NixOS Ubuntu/Debian, it may be most pragmatic for `bootstrap.sh` to run the official installer:

```bash
curl -fsSL https://tailscale.com/install.sh | sh
```

- if `TAILSCALE_AUTHKEY` is present, bootstrap can join the box automatically:

```bash
sudo tailscale up --ssh --auth-key "$TAILSCALE_AUTHKEY"
```

The auth key must never live in the public repo. Use environment variables or a secret manager.

Example one-command remote setup:

```bash
TAILSCALE_AUTHKEY=tskey-auth-... bash -c "$(curl -fsSL https://raw.githubusercontent.com/idobbins/devkit/main/bootstrap.sh)"
```

### Tailscale SSH

If Tailscale SSH is enabled, many boxes can be reached without manually copying SSH keys:

```bash
ssh ubuntu@devbox
```

Access should be controlled through Tailscale ACLs, not repo-managed host aliases.

Still generate `~/.ssh/id_ed25519` as a universal fallback for GitHub, non-Tailscale hosts, and tools expecting a standard key.

### Remote browser debugging

Preferred path when safe:

1. run the remote app bound to the Tailscale interface or all interfaces:

```bash
npm run dev -- --host 0.0.0.0
```

2. open locally:

```txt
http://devbox:3000
```

Use SSH tunnels when:

- the app only binds localhost
- the port should not be visible to the whole tailnet
- framework/browser behavior expects `localhost`
- a predictable local URL is desired

## SSH direction

Nix/Home Manager should manage portable SSH client defaults only.

Host-specific aliases live in:

```txt
~/.ssh/config.local
```

With Tailscale MagicDNS, many hosts may not need aliases at all.

Portable defaults should support reliable long-lived sessions:

```sshconfig
Host *
  ServerAliveInterval 30
  ServerAliveCountMax 3
  ControlMaster auto
  ControlPath ~/.ssh/control-%C
  ControlPersist 10m
  AddKeysToAgent yes
```

Idempotent key generation:

- create `~/.ssh/id_ed25519` only if missing
- never overwrite existing keys
- print public key after bootstrap

## Tunnel command

Provide a Nix-built `tunnel` helper via `pkgs.writeShellApplication`.

Desired UX:

```bash
tunnel devbox 3000
tunnel devbox 3000 5173 8000
tunnel devbox 8080:3000
tunnel --keep devbox 3000
```

Semantics:

```txt
localhost:3000 -> devbox:localhost:3000
localhost:8080 -> devbox:localhost:3000
```

Use `ssh -L` normally and `autossh` for `--keep`.

## Migration phases

### Phase 1: Flake foundation

- Add `flake.nix`.
- Add Home Manager Linux target.
- Add nix-darwin macOS target.
- Add core package module.
- Add zsh/git/ssh/tunnel modules.
- Add Determinate Nix `bootstrap.sh`.

### Phase 2: Neovim

- Replace current Lua/Lazy setup with `nixvim`.
- Preserve keybinds and essential behavior.
- Keep plugin set intentionally small.

### Phase 3: AI CLIs

- Add `pi`, `claude`, `codex`, and optionally `opencode`.
- Use pragmatic install route first, clean Nix packaging later.

### Phase 4: Cleanup

- Remove old Stow-oriented scripts/files once Nix path is working.
- Update README with one-command install instructions.
- Keep rollback instructions clear.

## Repo rename

`.dotfiles` undersells the direction once this becomes a Nix-powered dev environment.

Current preferred name: `devkit`.

Possible install path after rename:

```txt
~/.devkit
```

Possible bootstrap:

```bash
git clone https://github.com/idobbins/devkit ~/.devkit
~/.devkit/bootstrap.sh
```

Or remote one-liner:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/idobbins/devkit/main/bootstrap.sh)"
```

## Open decisions

- Final repo name (`devkit` is the current favorite).
- Whether to keep `nvm` as an optional user tool despite Nix-provided Node.
- Whether macOS casks should be managed through `nix-homebrew` immediately or added after core flake works.
- Exact AI CLI packaging strategy for each tool.
- Whether to use username-specific flake outputs or `--impure` dynamic user detection.
- Whether Tailscale install should be default on Linux or opt-in unless `TAILSCALE_AUTHKEY` exists.
- Whether Tailscale SSH should be assumed/recommended as the primary remote SSH path.
