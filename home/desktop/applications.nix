{
  lib,
  userConfig,
  ...
}:

let
  enabled = (userConfig.desktop.gnome.enable or false) || (userConfig.desktop.niri.enable or false);

  hiddenDesktopEntry = name: {
    inherit name;
    settings.Hidden = "true";
  };
in
{
  config = lib.mkIf enabled {
    xdg.desktopEntries = {
      cups = hiddenDesktopEntry "Manage Printing";
      qt5ct = hiddenDesktopEntry "Qt5 Settings";
      qt6ct = hiddenDesktopEntry "Qt6 Settings";
    };
  };
}
