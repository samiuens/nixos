{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.smi.desktop.niri;
in
{
  config = lib.mkIf (cfg.enable && cfg.shell == "dms") {
    programs.dms-shell = {
      enable = true;
      # Niri starts DMS, so it doesn't run in other sessions.
      systemd.enable = false;
    };

    environment.systemPackages = [
      pkgs.ddcutil
      pkgs.playerctl
    ];
  };
}
