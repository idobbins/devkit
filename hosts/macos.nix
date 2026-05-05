{ inputs, username, homeDirectory, ... }:
{
  imports = [
    inputs.home-manager.darwinModules.home-manager
    ../modules/darwin
  ];

  users.users.${username}.home = homeDirectory;

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = { inherit inputs username homeDirectory; };
  home-manager.sharedModules = [ inputs.nixvim.homeModules.nixvim ];
  home-manager.users.${username} = import ../modules/home;
}
