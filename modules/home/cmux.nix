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
}
