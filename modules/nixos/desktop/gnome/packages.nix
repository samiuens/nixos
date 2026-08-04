{
  lib,
  config,
  ...
}:

let
  cfg = config.smi.desktop.gnome;
in
{
  options.smi.desktop.gnome.enable = lib.mkEnableOption "GNOME desktop";

  config = lib.mkIf cfg.enable {
    services = {
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;

      gnome = {
        core-apps.enable = false;
        core-developer-tools.enable = false;
        games.enable = false;
      };
    };
  };
}
