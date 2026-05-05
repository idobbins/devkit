# Placeholder hardware config for the example host.
# Replace this file with `nixos-generate-config` output on real hardware.
{ lib, ... }:
{
  # fileSystems."/" = {
  #   device = "/dev/disk/by-uuid/00000000-0000-0000-0000-000000000000";
  #   fsType = "ext4";
  # };

  # boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "sd_mod" ];
  # boot.initrd.kernelModules = [ ];
  # boot.kernelModules = [ "kvm-intel" ];
  # swapDevices = [ ];

  # This is only an example; set this accurately on real hardware.
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
