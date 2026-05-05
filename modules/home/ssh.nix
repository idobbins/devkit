{ ... }:
{
  programs.ssh = {
    enable = true;
    includes = [ "~/.ssh/config.local" ];
    matchBlocks."*" = {
      serverAliveInterval = 30;
      serverAliveCountMax = 3;
      controlMaster = "auto";
      controlPath = "~/.ssh/control-%C";
      controlPersist = "10m";
      addKeysToAgent = "yes";
      extraOptions.ExitOnForwardFailure = "yes";
    };
  };
}
