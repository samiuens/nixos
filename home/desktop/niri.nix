{
  lib,
  osConfig,
  userConfig,
  ...
}:

let
  cfg = userConfig.desktop.niri or { };
  cursor = osConfig.smi.desktop.niri.cursor;
in
{
  config = lib.mkIf (cfg.enable or false) {
    home.pointerCursor = {
      enable = true;
      inherit (cursor) package name size;
      gtk.enable = true;
      x11.enable = true;
    };

    gtk.enable = true;

    xdg.configFile."niri/config.kdl".source = ./niri/config.kdl;
  };
}
