# Dotfiles

Personal system configuration managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Quick Start

```bash
git clone --recursive git@github.com:idobbins/.dotfiles.git ~/.dotfiles
~/.dotfiles/setup.sh
```

## Manual Setup

### 1. Xcode Command Line Tools

```bash
xcode-select --install
```

### 2. Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"
```

### 3. Clone Dotfiles

```bash
git clone --recursive git@github.com:idobbins/.dotfiles.git ~/.dotfiles
```

### 4. Install Packages

```bash
brew bundle --file=~/.dotfiles/Brewfile
```

### 5. Oh My Zsh

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
```

### 6. Create Symlinks

```bash
cd ~/.dotfiles && stow -t ~ .
```

## What's Included

- `.zshrc` - Zsh config with Oh My Zsh
- `.gitconfig` - Git identity + conditional work config
- `.config/nvim/` - Neovim configuration
- `.ssh/config` - SSH host aliases
- `.oh-my-zsh/custom/plugins/` - Zsh plugins (as submodules)
- `Brewfile` - Homebrew dependencies

## Update

```bash
cd ~/.dotfiles
git pull --recurse-submodules
```

## Refresh Symlinks

After adding or changing files, restow to update symlinks:

```bash
cd ~/.dotfiles && stow -t ~ -R .
```

## Add New Config

1. Move the file into `.dotfiles/` mirroring its home path
2. Run `stow -t ~ .` to create symlink
3. Commit and push

## Uninstall

Remove all symlinks (keeps dotfiles repo intact):

```bash
cd ~/.dotfiles && stow -t ~ -D .
```

Or run the uninstall script:

```bash
~/.dotfiles/uninstall.sh
```

This will:
- Remove all symlinks created by stow
- Restore any `.bak` files created during setup
- Leave the `~/.dotfiles` repo in place for re-installation
