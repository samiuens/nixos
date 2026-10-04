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
    environment.systemPackages = [ pkgs.xwayland-satellite ];
  };
}
