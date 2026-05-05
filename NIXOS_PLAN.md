# Add First-Class NixOS Support To Devkit

## Summary

Add NixOS as a first-class deployment target alongside the existing macOS and standalone Linux/Home Manager targets. The repo will support:

- `#macos`: macOS via nix-darwin + Home Manager
- `#linux`: guest/non-NixOS Linux via standalone Home Manager
- `#nixos`: headless NixOS servers/workstations via `nixos-rebuild`
- `nixosModules.devkit`: reusable NixOS module for machine-specific configs

The shared user environment remains in `modules/home`, while OS-level concerns stay split between `modules/darwin` and a new `modules/nixos`.

## Key Changes

- Add a NixOS system module at `modules/nixos/default.nix`.
  - Enable headless-friendly system defaults.
  - Enable `programs.zsh`.
  - Enable `services.openssh`.
  - Enable `services.tailscale`.
  - Configure the primary user with `isNormalUser = true`, `shell = pkgs.zsh`, and `extraGroups = [ "wheel" ]`.
  - Set `nixpkgs.config.allowUnfree = true`.
  - Avoid duplicating packages already managed by Home Manager.

- Add a NixOS host entry at `hosts/nixos.nix`.
  - Import `inputs.home-manager.nixosModules.home-manager`.
  - Import `../modules/nixos`.
  - Wire `home-manager.users.${username}` to the existing `modules/home`.
  - Reuse `inputs.nixvim.homeModules.nixvim`.
  - Use `home-manager.useGlobalPkgs = true` and `home-manager.useUserPackages = true`.

- Update `flake.nix`.
  - Keep existing `homeConfigurations.linux` and `darwinConfigurations.macos`.
  - Add:

    ```nix
    nixosConfigurations.nixos
    nixosModules.devkit
    ```

  - Use `linuxSystem` for the default NixOS target.
  - Pass `inputs`, `username`, and `homeDirectory = "/home/${username}"` through `specialArgs`.

- Add an example machine layout for real hardware.
  - Prefer a repo-owned path like:

    ```txt
    hosts/machines/example/configuration.nix
    hosts/machines/example/hardware-configuration.nix
    ```

  - The example should import the shared NixOS host layer and include placeholders for bootloader, filesystem, networking, and host name.
  - Do not make the example the default `#nixos` target unless it can evaluate without real hardware assumptions.

- Update the `devkit` helper.
  - Detect NixOS with `/etc/NIXOS`.
  - Apply targets as:
    - Darwin: `nix-darwin switch --flake "$DEVKIT_HOME#macos"`
    - NixOS: `sudo nixos-rebuild switch --flake "$DEVKIT_HOME#nixos"`
    - Other Linux: `home-manager switch --flake "$DEVKIT_HOME#linux"`
  - Update `status` and `doctor` output so NixOS is reported distinctly from generic Linux.
  - Keep `update`, `gc`, `edit`, and project helpers unchanged except where they call `apply`.

- Update `bootstrap.sh`.
  - On NixOS, skip apt/bootstrap package logic.
  - Assume Nix already exists on NixOS.
  - Clone or pull the repo as today.
  - Apply with `sudo nixos-rebuild switch --flake "$DEST#nixos"`.
  - Keep existing Ubuntu/Debian and macOS behavior unchanged.
  - Preserve optional SSH key creation and auth guidance after applying.

- Update `README.md`.
  - Document the three supported modes: macOS, guest Linux, NixOS.
  - Add direct commands for:

    ```bash
    devkit apply
    sudo nixos-rebuild switch --flake ~/.devkit#nixos
    nix --option nix-path "" run home-manager -- switch --flake ~/.devkit#linux --impure
    nix --option nix-path "" run nix-darwin -- switch --flake ~/.devkit#macos --impure
    ```

  - Explain that `#linux` is for non-NixOS Linux and `#nixos` is for full NixOS machines.
  - Explain where host-specific hardware config should live.

## Test Plan

- Run flake checks/evaluation:
  - `nix flake show`
  - `nix eval .#nixosConfigurations.nixos.config.system.build.toplevel.drvPath`
  - `nix eval .#homeConfigurations.linux.activationPackage.drvPath`
  - `nix eval .#darwinConfigurations.macos.system`

- Validate shell helper behavior without switching the host:
  - Inspect `devkit status` on the current machine.
  - On a NixOS machine, verify `devkit doctor` reports the NixOS target.
  - On a NixOS machine, run `devkit apply` and confirm it invokes `nixos-rebuild`.

- Validate NixOS behavior on a real or VM host:
  - Clone repo to `~/.devkit`.
  - Run `sudo nixos-rebuild switch --flake ~/.devkit#nixos`.
  - Confirm the configured user exists.
  - Confirm zsh, SSH, Tailscale, Home Manager packages, Neovim, AI CLIs, aliases, and `devkit` are available.
  - Confirm `devkit update` pulls and reapplies the NixOS config.

- Regression-check existing targets:
  - macOS still evaluates through `darwinConfigurations.macos`.
  - guest Linux still applies through standalone Home Manager.
  - No package/module logic is moved out of `modules/home` unless it is truly system-level.

## Assumptions And Defaults

- Primary NixOS target is headless server/workstation usage, not desktop GUI management.
- The default NixOS target name will be `#nixos`.
- Shared user tooling continues to live in `modules/home`.
- NixOS system services and users live in `modules/nixos`.
- Host-specific hardware, disks, bootloader, and networking stay in machine-specific files or external `/etc/nixos` imports.
- `services.openssh` and `services.tailscale` are enabled by default for NixOS because these machines are expected to be headless.
- The default user remains derived from `$USER`, falling back to `idobbins`, matching the existing flake behavior.
