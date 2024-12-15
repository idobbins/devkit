{
  description = "Unified development environment";

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
    
    # Single definition of packages used everywhere
    commonPackages = with pkgs; [
      # Development tools
      cmake
      ripgrep

      # Languages and tooling
      python3
      poetry
      black
      rustc
      cargo
      rust-analyzer

      # Neovim and dependencies
      neovim
      nodejs # Required for some LSP servers
      git # For lazy.nvim
      
      # Language Servers (from init.lua)
      nodePackages.bash-language-server
      clang-tools # Provides clangd
      cmake-language-server
      nodePackages.csharp-language-server
      nodePackages.emmet-ls
      haskell-language-server
      nodePackages.pyright
      rust-analyzer
      nodePackages.typescript-language-server
      terraform-ls
      lua-language-server
      
      # Tree-sitter dependencies
      tree-sitter
      
      # Additional tools needed by plugins
      lazygit # For lazygit.nvim
      fzf # For telescope-fzf-native
      gcc # Required for building some dependencies

      # Mason dependencies
      wget
      unzip
      gzip
    ];
  in {
    # This makes the development environment automatically active in the project directory
    devShells.${system}.default = pkgs.mkShell {
      packages = commonPackages;
    };

    homeConfigurations."idobbins" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      
      modules = [{
        home = {
          username = "idobbins";
          homeDirectory = "/Users/idobbins";
          packages = commonPackages;
          stateVersion = "23.11";
        };
        
        programs.home-manager.enable = true;

        programs.neovim = {
          enable = true;
          viAlias = true;
          vimAlias = true;
          defaultEditor = true;
          extraLuaConfig = ''
            ${builtins.readFile ./nvim/init.lua}
          '';
        };
      }];
    };
  };
}
