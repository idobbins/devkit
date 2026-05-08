{ pkgs, ... }:
let
  codexPackage =
    if pkgs.stdenv.isDarwin
    then pkgs.callPackage ../../pkgs/codex-bin { }
    else pkgs.codex;
  ampcodePackage = pkgs.callPackage ../../pkgs/ampcode { };
in
{
  home.packages = with pkgs; [
    pi-coding-agent
    claude-code
    codexPackage
    ampcodePackage
  ];
}
