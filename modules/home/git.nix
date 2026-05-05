{ ... }:
{
  programs.git = {
    enable = true;
    userName = "Isaac Dobbins";
    lfs.enable = true;
    ignores = [
      ".DS_Store"
      ".AppleDouble"
      ".LSOverride"
      "._*"
      "*.swp"
      "*.swo"
      "*~"
      "\\#*\\#"
      ".#*"
      "*.un~"
      "Session.vim"
      ".netrwhist"
      "*.log"
      "*.local"
      ".localrc"
    ];
    extraConfig = {
      core.editor = "nvim";
      init.defaultBranch = "main";
      pull.rebase = false;
      fetch.prune = true;
      push.autoSetupRemote = true;
      include.path = "~/.gitconfig.local";
    };
  };
}
