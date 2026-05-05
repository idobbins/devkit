{ pkgs, ... }:
{
  home.packages = with pkgs; [
    gh
    ripgrep fd jq yq-go
    bat eza tree tmux
    curl wget rsync unzip gnupg openssh coreutils file
  ];
}
