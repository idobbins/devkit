{ pkgs, username, ... }:
{
  nixpkgs.config.allowUnfree = true;

  programs.zsh.enable = true;
  environment.shells = [ pkgs.zsh ];

  services.openssh.enable = true;
  services.tailscale.enable = true;

  users.users.${username} = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" ];
  };

  security.sudo.wheelNeedsPassword = true;

  networking.networkmanager.enable = false;
  documentation.enable = false;
}
