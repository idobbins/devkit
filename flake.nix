{
  description = "Development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { nixpkgs, ... }:
  let
    system = "aarch64-darwin";
    pkgs = nixpkgs.legacyPackages.${system};
    
    # Create neovim with custom configuration and plugins
    customNeovim = pkgs.neovim.override {
      configure = {
        customRC = builtins.readFile ./nvim/init.lua;
        packages.myVimPackage = with pkgs.vimPlugins; {
          start = [
            # Icons
            nvim-web-devicons

            # Telescope and dependencies
            telescope-nvim
            plenary-nvim
            telescope-fzf-native-nvim

            # Treesitter
            nvim-treesitter.withAllGrammars

            # Git integration
            lazygit-nvim

            # LSP and completion
            nvim-lspconfig
            nvim-cmp
            cmp-buffer
            cmp-path
            cmp_luasnip
            cmp-nvim-lsp
            cmp-nvim-lua

            # Snippets
            luasnip
            friendly-snippets

            # UI enhancements
            lualine-nvim
            dressing-nvim
            nvim-notify
            vim-config-local
            trouble-nvim
            
            # Theme
            catppuccin-nvim
          ];
        };
      };
    };
  in {
    packages.${system}.default = pkgs.buildEnv {
      name = "dev-environment";
      paths = with pkgs; [
        # Development tools
        cmake
        ripgrep
        zlib
        zlib.dev
        pkg-config

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
        nodejs
        git
        
        # Language Servers
        bash-language-server
        clang-tools
        cmake-language-server
        omnisharp-roslyn
        emmet-language-server
        fsautocomplete
        haskell-language-server
        pyright
        rust-analyzer
        tailwindcss-language-server
        typescript-language-server
        terraform-ls
        lua-language-server
        
        # Tree-sitter dependencies
        tree-sitter
        
        # Additional tools
        lazygit
        fzf
        customNeovim  # Use our custom neovim instead of the default one
      ];
      
      pathsToLink = [ "/bin" "/share" "/lib" "/include" ];
      extraOutputsToInstall = [ "dev" ];
    };
  };
}
