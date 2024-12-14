{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager }: let
    system = "aarch64-darwin";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    homeConfigurations."${builtins.getEnv "USER"}" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      
      modules = [{
        home = {
          username = builtins.getEnv "USER";
          homeDirectory = builtins.getEnv "HOME";
          stateVersion = "23.11";
          packages = with pkgs; [
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
