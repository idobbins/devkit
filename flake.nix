{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };
  outputs = { nixpkgs, ... }: let
    pkgs = import nixpkgs { system = builtins.currentSystem; };
  in {
    packages.${builtins.currentSystem}.default = pkgs.buildEnv {
      name = "my-packages";
      paths = with pkgs; [

        cmake
        git
	jq
        neovim
        ripgrep

	nodejs_latest

      ];
    };
  };

