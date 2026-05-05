{ pkgs, ... }:
{
  home.packages = with pkgs; [
    pi-coding-agent
    claude-code
    codex
  ];
}
