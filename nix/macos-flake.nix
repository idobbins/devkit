{
  description = "MacOS system configuration";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { nixpkgs, home-manager, ... }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
      username = builtins.getEnv "USER";
    in {
      packages.${system}.default = pkgs.symlinkJoin {
        name = "home-manager-config";
        paths = [ ];
      };

      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        
        modules = [
          {
            home = {
              username = username;
              homeDirectory = builtins.getEnv "HOME";
              stateVersion = "23.11";
              packages = with pkgs; [
                cmake
                git
                jq
                neovim
                ripgrep
              ];
            };
            programs = {
              home-manager.enable = true;
              
              git = {
                enable = true;
                userName = "Isaac Dobbins";
                userEmail = "isaac.dobbins@icloud.com";
                extraConfig = {
                  init.defaultBranch = "dev";
                  pull.rebase = true;
                };
              };
              neovim = {
                enable = true;
                defaultEditor = true;
              };
            };
            xdg.configFile = {
              "nvim" = {
                source = ./nvim;
                recursive = true;
              };
            };
          }
        ];
      };
      formatter.${system} = pkgs.nixpkgs-fmt;
    };
}
