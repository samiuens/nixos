{
  lib,
  pkgs,
  userConfig,
  ...
}:

let
  cfg = userConfig.desktop.gnome or { };

  extensions = with pkgs.gnomeExtensions; [
    appindicator
    blur-my-shell
  ];
in
{
  config = lib.mkIf (cfg.enable or false) {
    home.packages = extensions;

    dconf.settings."org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = map (extension: extension.extensionUuid) extensions;
    };
  };
}
