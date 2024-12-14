{
  description = "Minimal flake with development tools";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { nixpkgs, ... }: {
    packages.aarch64-darwin = 
      let 
        pkgs = import nixpkgs { system = "aarch64-darwin"; };
      in {
        default = pkgs.symlinkJoin {
          name = "dev-tools";
          paths = with pkgs; [
            neovim
            cmake
            jq
          ];
        };
      };
  };
}
