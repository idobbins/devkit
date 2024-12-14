{
  description = "Minimal flake with development tools";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { nixpkgs, ... }: {
    nixosConfigurations."aarch64-darwin" = nixpkgs.lib.nixosSystem {
      system = "aarch64-darwin";
      modules = [{
        environment.systemPackages = with nixpkgs.legacyPackages.aarch64-darwin; [
          neovim
          cmake
          jq
        ];
      }];
    };
  };
}
