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
      username = "idobbins";
      homeDirectory = "/Users/${username}";
    in {
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        
        modules = [
          {
            home = {
              inherit username homeDirectory;
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

            # The source directory will be symlinked to the target
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
