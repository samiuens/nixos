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
  config = lib.mkIf cfg.enable {
    programs.noctalia = {
      enable = true;
      recommendedServices.enable = true;
    };

    environment.systemPackages = [
      pkgs.ddcutil
      pkgs.playerctl
    ];

    hardware.i2c.enable = true;
  };
}
