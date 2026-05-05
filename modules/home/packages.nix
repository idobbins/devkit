{ pkgs, ... }:
{
  home.packages = with pkgs; [
    git git-lfs gh neovim ripgrep fd fzf jq yq-go bat eza tree tmux direnv
    curl wget rsync unzip gnupg openssh autossh cmake gnumake pkg-config uv
    nodejs_24 pnpm bun deno rustup awscli2 postgresql_16
  ];
}
