#!/bin/bash

set -e

NVIM_CONFIG_DIR="$HOME/.config/nvim"
BACKUP_DIR="$HOME/.config/nvim.backup.$(date +%s)"
REPO_URL="https://idobbins.github.io/env/"

echo "🚀 Installing neovim config..."

# Detect OS and package manager
OS="$(uname -s)"
DISTRO=""
PKG_MANAGER=""

case "$OS" in
    Linux*)
        OS="Linux"
        if command -v apt &> /dev/null; then
            PKG_MANAGER="apt"
            DISTRO="debian"
        elif command -v yum &> /dev/null; then
            PKG_MANAGER="yum"
            DISTRO="rhel"
        elif command -v dnf &> /dev/null; then
            PKG_MANAGER="dnf"
            DISTRO="rhel"
        elif command -v pacman &> /dev/null; then
            PKG_MANAGER="pacman"
            DISTRO="arch"
        elif command -v apk &> /dev/null; then
            PKG_MANAGER="apk"
            DISTRO="alpine"
        fi
        ;;
    Darwin*)
        OS="macOS"
        if command -v brew &> /dev/null; then
            PKG_MANAGER="brew"
        fi
        ;;
    *)
        echo "⚠️  Unsupported OS: $OS (but proceeding anyway)"
        OS="Unknown"
        ;;
esac

echo "🖥️  Detected: $OS ${DISTRO:+($DISTRO)}"

# Function to install packages
install_deps() {
    local deps=("$@")
    echo "📦 Installing dependencies: ${deps[*]}"
    
    case "$PKG_MANAGER" in
        "brew")
            brew install "${deps[@]}"
            ;;
        "apt")
            sudo apt update && sudo apt install -y "${deps[@]}"
            ;;
        "yum"|"dnf")
            sudo $PKG_MANAGER install -y "${deps[@]}"
            ;;
        "pacman")
            sudo pacman -Sy --noconfirm "${deps[@]}"
            ;;
        "apk")
            sudo apk add "${deps[@]}"
            ;;
        *)
            echo "❌ No supported package manager found"
            return 1
            ;;
    esac
}

# Check if nvim is installed, offer to install it
if ! command -v nvim &> /dev/null; then
    echo "❌ Neovim not found."
    if [ -n "$PKG_MANAGER" ]; then
        echo "🤔 Would you like to install neovim? (y/N)"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            case "$PKG_MANAGER" in
                "brew") install_deps neovim ;;
                "apt") install_deps neovim ;;
                "yum"|"dnf") install_deps neovim ;;
                "pacman") install_deps neovim ;;
                "apk") install_deps neovim ;;
            esac
        else
            echo "Please install neovim manually and re-run this script."
            exit 1
        fi
    else
        echo "Please install neovim manually and re-run this script."
        exit 1
    fi
fi

# Backup existing config
if [ -d "$NVIM_CONFIG_DIR" ]; then
    echo "📦 Backing up existing config to $BACKUP_DIR"
    mv "$NVIM_CONFIG_DIR" "$BACKUP_DIR"
fi

# Create nvim config directory
mkdir -p "$NVIM_CONFIG_DIR"

# Download init.lua
echo "📥 Downloading configuration..."
if command -v curl &> /dev/null; then
    curl -fsSL "$REPO_URL/nvim/init.lua" -o "$NVIM_CONFIG_DIR/init.lua"
elif command -v wget &> /dev/null; then
    wget -q "$REPO_URL/nvim/init.lua" -O "$NVIM_CONFIG_DIR/init.lua"
else
    echo "❌ Neither curl nor wget found. Cannot download config."
    exit 1
fi

# Check for build dependencies
echo "🔍 Checking dependencies..."
MISSING_DEPS=()
INSTALL_DEPS=()

# Map missing deps to package names for different distros
check_and_map_dep() {
    local cmd="$1"
    local debian_pkg="$2"
    local rhel_pkg="$3"
    local arch_pkg="$4"
    local alpine_pkg="$5"
    local macos_pkg="$6"
    
    if ! command -v "$cmd" &> /dev/null; then
        MISSING_DEPS+=("$cmd")
        case "$PKG_MANAGER" in
            "apt") INSTALL_DEPS+=("$debian_pkg") ;;
            "yum"|"dnf") INSTALL_DEPS+=("$rhel_pkg") ;;
            "pacman") INSTALL_DEPS+=("$arch_pkg") ;;
            "apk") INSTALL_DEPS+=("$alpine_pkg") ;;
            "brew") INSTALL_DEPS+=("$macos_pkg") ;;
        esac
    fi
}

check_and_map_dep "git" "git" "git" "git" "git" "git"
check_and_map_dep "cmake" "cmake" "cmake" "cmake" "cmake" "cmake"
check_and_map_dep "make" "build-essential" "make" "base-devel" "build-base" ""

# Check for C compiler
if ! command -v gcc &> /dev/null && ! command -v clang &> /dev/null && ! command -v cc &> /dev/null; then
    MISSING_DEPS+=("C compiler")
    case "$PKG_MANAGER" in
        "apt") INSTALL_DEPS+=("build-essential") ;;
        "yum"|"dnf") INSTALL_DEPS+=("gcc-c++") ;;
        "pacman") INSTALL_DEPS+=("base-devel") ;;
        "apk") INSTALL_DEPS+=("build-base") ;;
        "brew") ;; # Xcode tools handled separately
    esac
fi

if [ ${#MISSING_DEPS[@]} -ne 0 ]; then
    echo "⚠️  Missing dependencies: ${MISSING_DEPS[*]}"
    
    if [ -n "$PKG_MANAGER" ] && [ ${#INSTALL_DEPS[@]} -gt 0 ]; then
        echo "🤔 Would you like to install missing dependencies? (y/N)"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            # Remove duplicates from INSTALL_DEPS
            INSTALL_DEPS=($(printf "%s\n" "${INSTALL_DEPS[@]}" | sort -u))
            
            # Special handling for macOS build tools
            if [ "$OS" = "macOS" ] && [[ " ${MISSING_DEPS[*]} " =~ " C compiler " ]]; then
                echo "📦 Installing Xcode command line tools..."
                xcode-select --install 2>/dev/null || echo "ℹ️  Xcode tools may already be installed"
            fi
            
            if [ ${#INSTALL_DEPS[@]} -gt 0 ]; then
                install_deps "${INSTALL_DEPS[@]}"
            fi
        else
            echo "   Some plugins (especially telescope-fzf-native) may not work."
        fi
    else
        echo "   Some plugins may not work properly."
        echo "   Install these packages manually for full functionality."
    fi
else
    echo "✅ All dependencies found!"
fi

echo "✅ Config installed! Run 'nvim' to start."
echo "   Lazy.nvim will install plugins automatically on first run."
echo "   Press 'q' to close the Lazy installer when it's done."

if [ -d "$BACKUP_DIR" ]; then
    echo "📝 Your old config is backed up at: $BACKUP_DIR"
    echo "   Delete it with: rm -rf \"$BACKUP_DIR\""
fi
