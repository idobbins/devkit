{ config, lib, pkgs, ... }:
let
  settingsFile = "${config.home.homeDirectory}/.pi/agent/settings.json";
  devkitPackage = "${config.home.homeDirectory}/.devkit";
  jq = "${pkgs.jq}/bin/jq";
in
{
  home.activation.devkitPiSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    settings_dir="$HOME/.pi/agent"
    settings_file="${settingsFile}"
    devkit_package="${devkitPackage}"

    mkdir -p "$settings_dir"
    if [ ! -f "$settings_file" ]; then
      printf '{}\n' > "$settings_file"
    fi

    tmp="$(${pkgs.coreutils}/bin/mktemp)"
    ${jq} --arg pkg "$devkit_package" '
      .theme = "light"
      | .defaultThinkingLevel = (.defaultThinkingLevel // "low")
      | .packages = (((.packages // []) | map(select(. != $pkg))) + [$pkg])
    ' "$settings_file" > "$tmp"
    ${pkgs.coreutils}/bin/mv "$tmp" "$settings_file"
  '';
}
