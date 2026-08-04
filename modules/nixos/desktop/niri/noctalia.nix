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
    programs.noctalia = {
      enable = true;
      recommendedServices.enable = true;
    };
  };
}
