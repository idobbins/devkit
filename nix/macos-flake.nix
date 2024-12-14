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
    in {
      homeManagerConfigurations = username: homeDirectory: {
        ${username} = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit username homeDirectory; };
          
          modules = [{
            home = {
              inherit username homeDirectory;
              stateVersion = "24.05";
              packages = with pkgs; [
                # Development tools
                cmake
                git
                jq
                neovim
                ripgrep
                
                # macOS specific tools
                coreutils
                gnused
                gawk
                findutils
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
          }];
        };
      };
      formatter.${system} = pkgs.nixpkgs-fmt;
    };
}
