{ pkgs, ... }:
{
  home.packages = [
    (pkgs.writeShellApplication {
      name = "devkit";
      runtimeInputs = [ pkgs.git pkgs.jq ];
      text = builtins.readFile ../../.local/bin/devkit;
    })
  ];
}
