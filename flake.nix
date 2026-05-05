{
  description = "Portable Nix-powered dev environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };

  outputs = inputs@{ self, nixpkgs, home-manager, nix-darwin, nixvim, nix-homebrew, ... }:
    let
      username = let env = builtins.getEnv "USER"; in if env == "" then "idobbins" else env;
      linuxHome = let env = builtins.getEnv "HOME"; in if env == "" then "/home/${username}" else env;
      darwinHome = let env = builtins.getEnv "HOME"; in if env == "" then "/Users/${username}" else env;
      currentSystem = let env = builtins.getEnv "NIX_SYSTEM"; in if env != "" then env else builtins.currentSystem or "aarch64-darwin";
      linuxSystem = if currentSystem == "x86_64-linux" || currentSystem == "aarch64-linux" then currentSystem else "x86_64-linux";
      darwinSystem = if currentSystem == "x86_64-darwin" || currentSystem == "aarch64-darwin" then currentSystem else "aarch64-darwin";
    in {
      homeConfigurations.linux = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs { system = linuxSystem; config.allowUnfree = true; };
        extraSpecialArgs = { inherit inputs username; homeDirectory = linuxHome; };
        modules = [ nixvim.homeManagerModules.nixvim ./hosts/linux.nix ];
      };

      darwinConfigurations.macos = nix-darwin.lib.darwinSystem {
        system = darwinSystem;
        specialArgs = { inherit inputs username; homeDirectory = darwinHome; };
        modules = [ ./hosts/macos.nix ];
      };
    };
}
