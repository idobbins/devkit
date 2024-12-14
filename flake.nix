{
  description = "System and development environments";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }: 
  let
    system = "aarch64-darwin";
    pkgs = nixpkgs.legacyPackages.${system};
    
    # Define base packages that should be in every shell
    basePackages = with pkgs; [
      neovim
      cmake
      ripgrep
    ];
  in {
    # Development shells for project-specific work
    devShells.${system} = {
      default = pkgs.mkShell {
        packages = basePackages;
      };

      python = pkgs.mkShell {
        packages = basePackages ++ (with pkgs; [
          python3
          poetry
          black
        ]);
      };

      rust = pkgs.mkShell {
        packages = basePackages ++ (with pkgs; [
          rustc
          cargo
          rust-analyzer
        ]);
      };
    };

    # Home Manager configuration
    homeConfigurations."idobbins" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      
      modules = [{
        home = {
          username = "idobbins";
          homeDirectory = "/Users/idobbins";
          packages = basePackages;
          
          # Don't change these
          stateVersion = "23.11";
        };
        
        # Let home-manager manage itself
        programs.home-manager.enable = true;
      }];
    };
  };
}
