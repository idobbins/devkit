{ pkgs, ... }:
{
  home.sessionPath = [
    "/etc/profiles/per-user/$USER/bin"
    "$HOME/.nix-profile/bin"
    "/run/current-system/sw/bin"
    "/nix/var/nix/profiles/default/bin"
    "$HOME/.local/bin"
    "$HOME/bin"
    "$HOME/.cargo/bin"
    "$HOME/.bun/bin"
    "$HOME/.deno/bin"
    "$HOME/.local/share/pnpm"
    "/usr/local/bin"
  ];

  home.packages = with pkgs; [
    gh
    ripgrep fd jq yq-go
    bat eza tree tmux
    curl wget rsync unzip gnupg openssh coreutils file

    nodejs
    nil
    nixd
    lua-language-server
    typescript
    typescript-language-server
    pyright
    rust-analyzer
    vscode-langservers-extracted
    yaml-language-server
    bash-language-server
    taplo
    marksman
  ];
}
