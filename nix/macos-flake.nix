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
      homeManagerConfigurations.idobbins = home-manager.lib.homeManagerConfiguration {  # Replace with your username
        inherit pkgs;
        
        modules = [{
          home = {
            username = "idobbins";  # Replace with your username
            homeDirectory = "/Users/idobbins";  # Replace with your home directory
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
      formatter.${system} = pkgs.nixpkgs-fmt;
    };
}
