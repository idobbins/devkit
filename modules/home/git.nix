{ ... }:
{
  programs.git = {
    enable = true;
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
    settings = {
      user.name = "Isaac Dobbins";
      core.editor = "nvim";
      init.defaultBranch = "main";
      pull.rebase = false;
      fetch.prune = true;
      push.autoSetupRemote = true;
      include.path = "~/.gitconfig.local";
    };
  };
}
