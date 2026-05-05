{ inputs, lib, username, homeDirectory, ... }:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ../modules/nixos
  ];

  networking.hostName = "nixos";

  # Generic defaults so `#nixos` can evaluate without committing this repo to
  # any specific disk layout. Real hosts should override these in
  # hosts/machines/<name>/configuration.nix.
  boot.loader.grub.enable = lib.mkDefault false;
  fileSystems."/" = lib.mkDefault {
    device = "none";
    fsType = "tmpfs";
  };

  system.stateVersion = "24.11";

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "hm-backup";
  home-manager.extraSpecialArgs = { inherit inputs username homeDirectory; };
  home-manager.sharedModules = [ inputs.nixvim.homeModules.nixvim ];
  home-manager.users.${username} = import ../modules/home;
}
