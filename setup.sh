#!/bin/bash
set -e

echo "==> Setting up dotfiles..."

# 1. Xcode Command Line Tools
if ! xcode-select -p &>/dev/null; then
    echo "==> Installing Xcode Command Line Tools..."
    xcode-select --install
    echo "Press enter when installation is complete..."
    read -r
else
    echo "==> Xcode CLT already installed"
fi

# 2. Homebrew
if ! command -v brew &>/dev/null; then
    echo "==> Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo "==> Homebrew already installed"
fi

# 3. Homebrew packages
echo "==> Installing Homebrew packages..."
brew bundle --file=~/.dotfiles/Brewfile --no-lock

# 4. Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "==> Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "==> Oh My Zsh already installed"
fi

# 5. Stow dotfiles
echo "==> Creating symlinks with stow..."

# Remove existing files that would conflict (backup first)
for file in .zshrc .gitconfig .gitconfig-fundlaunch; do
    if [ -f "$HOME/$file" ] && [ ! -L "$HOME/$file" ]; then
        echo "    Backing up ~/$file to ~/$file.bak"
        mv "$HOME/$file" "$HOME/$file.bak"
    fi
done

# Remove existing symlinks or directories that conflict
[ -L "$HOME/.config/nvim" ] && rm "$HOME/.config/nvim"
[ -L "$HOME/.ssh/config" ] && rm "$HOME/.ssh/config"

# Ensure .ssh directory exists with correct permissions
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

# Remove existing oh-my-zsh plugin directories (not symlinks)
for plugin in zsh-autosuggestions zsh-syntax-highlighting zsh-bat zsh-nvm you-should-use; do
    target="$HOME/.oh-my-zsh/custom/plugins/$plugin"
    if [ -d "$target" ] && [ ! -L "$target" ]; then
        rm -rf "$target"
    elif [ -L "$target" ]; then
        rm "$target"
    fi
done

cd ~/.dotfiles && stow -t ~ .

echo "==> Done! Restart your shell or run: source ~/.zshrc"
