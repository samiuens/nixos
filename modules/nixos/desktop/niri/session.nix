{
  config,
  lib,
  ...
}:

let
  cfg = config.smi.desktop.niri;
in
{
  options.smi.desktop.niri.enable = lib.mkEnableOption "Niri desktop with Noctalia Shell";

  config = lib.mkIf cfg.enable {
    programs.niri.enable = true;
    services.udisks2.enable = true;
  };
}
