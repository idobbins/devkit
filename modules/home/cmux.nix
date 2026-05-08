{ ... }:
{
  home.file.".config/cmux/cmux.json".text = ''
    {
      "$schema": "https://raw.githubusercontent.com/manaflow-ai/cmux/main/web/data/cmux.schema.json",
      "schemaVersion": 1,
      "app": {
        "appearance": "light"
      },
      "browser": {
        "theme": "light"
      }
    }
  '';

  home.file."Library/Application Support/com.cmuxterm.app/config.ghostty".text = ''
    font-family = "Geist Mono"

    # cmux themes start
    theme = light:Ayu Light,dark:Ayu Light
    # cmux themes end
  '';
}
