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

  manual.manpages.enable = false;
  manual.html.enable = false;
  manual.json.enable = false;

  home.stateVersion = "24.11";
}
