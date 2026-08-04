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
    # Niri starts xwayland-satellite on demand for applications that still
    # require X11.
    environment.systemPackages = [ pkgs.xwayland-satellite ];
  };
}
