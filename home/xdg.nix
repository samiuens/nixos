{ config, ... }:

let
  homeDirectory = config.home.homeDirectory;
in
{
  xdg.userDirs = {
    enable = true;
    createDirectories = true;

    desktop = null;
    documents = "${homeDirectory}/Documents";
    download = "${homeDirectory}/Downloads";
    music = null;
    pictures = "${homeDirectory}/Pictures";
    projects = null;
    publicShare = null;
    templates = null;
    videos = "${homeDirectory}/Videos";
  };
}
