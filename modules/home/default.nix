{ ... }:
{
  imports = [
    ./packages.nix
    ./zsh.nix
    ./git.nix
    ./ssh.nix
    ./tunnel.nix
    ./devkit.nix
    ./neovim.nix
    ./ai.nix
  ];

  programs.home-manager.enable = true;
  home.stateVersion = "24.11";
}
