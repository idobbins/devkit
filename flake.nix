{
  description = "Development environments for different tasks";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { nixpkgs, ... }: 
  let
    system = "aarch64-darwin";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    devShells.${system} = {
      default = pkgs.mkShell {
        packages = with pkgs; [
          neovim
          cmake
          jq
        ];
      };

      python = pkgs.mkShell {
        packages = with pkgs; [
          python3
          poetry
          black
          pylint
        ];
      };

      nodejs = pkgs.mkShell {
        packages = with pkgs; [
          nodejs_20
          yarn
          nodePackages.typescript
          nodePackages.typescript-language-server
        ];
      };

      rust = pkgs.mkShell {
        packages = with pkgs; [
          rustc
          cargo
          rust-analyzer
          clippy
        ];
      };
    };
  };
}
