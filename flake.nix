{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }: let
    system = "aarch64-darwin";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    packages.${system}.default = pkgs.buildEnv {
      name = "my-packages";
      paths = with pkgs; [
        cmake
        git
        neovim
        ripgrep
      ];
    };
  };
}
