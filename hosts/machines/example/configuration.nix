# Example real-machine NixOS configuration.
# Copy this directory for a host and fill in hardware, disks, boot, and network details.
{ ... }:
{
  imports = [
    ../../nixos.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "devkit-example";

  # Pick the bootloader appropriate for your machine.
  # boot.loader.systemd-boot.enable = true;
  # boot.loader.efi.canTouchEfiVariables = true;
  # boot.loader.grub.enable = true;
  # boot.loader.grub.device = "/dev/sda";

  # Host-specific networking belongs here.
  # networking.networkmanager.enable = true;
  # networking.interfaces.enp1s0.useDHCP = true;

  # Keep host-specific services and hardware choices here, not in modules/home.
}
