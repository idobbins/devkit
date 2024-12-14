i{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }: {
    defaultPackage.aarch64-darwin = 
      home-manager.defaultPackage.aarch64-darwin;

    homeConfigurations.idobbins = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.aarch64-darwin;
      
      modules = [{
        home = {
          username = "idobbins";
          homeDirectory = "/Users/idobbins";
          stateVersion = "23.11";
          packages = with nixpkgs.legacyPackages.aarch64-darwin; [
            cmake
            git
            neovim
            ripgrep
            nushell
          ];
        };

        programs = {
          home-manager.enable = true;
          nushell.enable = true;
        };

        targets.darwin.enable = true;
      }];
    };
  };
}
