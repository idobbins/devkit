{ pkgs, ... }:
{
  home.packages = [
    (pkgs.writeShellApplication {
      name = "tunnel";
      runtimeInputs = [ pkgs.openssh pkgs.autossh pkgs.jq ];
      text = builtins.readFile ../../.local/bin/tunnel;
    })
  ];
}
