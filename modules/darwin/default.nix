{ pkgs, username, ... }:
{
  nix.enable = false;
  nixpkgs.config.allowUnfree = true;

  programs.zsh.enable = true;
  environment.shells = [ pkgs.zsh ];

  system.primaryUser = username;
  system.stateVersion = 5;
}
