{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = { self, nixpkgs }: let
    system = "aarch64-darwin";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    packages.${system}.default = pkgs.symlinkJoin {
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
