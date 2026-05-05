{ ... }:
{
  programs.git = {
    enable = true;
    userName = "Isaac Dobbins";
    lfs.enable = true;
    ignores = [ ];
    extraConfig = {
      core = { editor = "nvim"; excludesfile = "~/.config/git/ignore"; };
      init.defaultBranch = "main";
      pull.rebase = false;
      fetch.prune = true;
      push.autoSetupRemote = true;
      include.path = "~/.gitconfig.local";
    };
  };
}
