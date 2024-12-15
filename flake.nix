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
    
    commonPackages = with pkgs; [
      # Development tools
      cmake
      ripgrep

      # Languages and tooling
      python3
      poetry
      black

      # Rust tooling
      cargo
      rustc
      clippy
      rustfmt
        
      # Haskell tooling
      ghc
      cabal-install
      haskellPackages.ghcid

      # Dependencies for neovim plugins
      nodejs # Required for some LSP servers
      git # For lazy.nvim
      
      # Language Servers (matching init.lua configuration)
      bash-language-server      # bashls
      clang-tools              # clangd
      cmake-language-server    # cmake
      omnisharp-roslyn        # csharp_ls
      emmet-language-server   # emmet_ls
      fsautocomplete          # fsautocomplete
      haskell-language-server # hls
      pyright                 # pyright
      rust-analyzer           # rust_analyzer
      tailwindcss-language-server # tailwindcss
      typescript-language-server  # tsserver
      terraform-ls            # terraformls
      lua-language-server     # lua_ls
      
      # Tree-sitter dependencies
      tree-sitter
      
      # Additional tools needed by plugins
      lazygit # For lazygit.nvim
      fzf # For telescope-fzf-native
    ];
  in {
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
