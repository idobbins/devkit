{ inputs, username, homeDirectory, ... }:
{
  imports = [
    inputs.home-manager.darwinModules.home-manager
    inputs.nix-homebrew.darwinModules.nix-homebrew
    ../modules/darwin
    ../modules/darwin/homebrew.nix
  ];

  users.users.${username}.home = homeDirectory;

  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    user = username;
  };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = { inherit inputs username homeDirectory; };
  home-manager.sharedModules = [ inputs.nixvim.homeManagerModules.nixvim ];
  home-manager.users.${username} = import ../modules/home;
}
