{ pkgs, ... }:
{
  home.packages = [
    (pkgs.writeShellApplication {
      name = "tunnel";
      runtimeInputs = [ pkgs.openssh pkgs.autossh ];
      text = builtins.readFile ../../.local/bin/tunnel;
    })
  ];
}
