{ username, homeDirectory, ... }:
{
  imports = [ ../modules/home ];
  home.username = username;
  home.homeDirectory = homeDirectory;
}
