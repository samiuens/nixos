{
  config,
  lib,
  ...
}:

let
  cfg = config.smi.desktop.niri;
in
{
  config = lib.mkIf cfg.enable {
    services.geoclue2.enable = true;
  };
}
