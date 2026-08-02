{
  lib,
  config,
  ...
}:

let
  cfg = config.smi.hardware.power;
in
{
  options.smi.hardware.power = {
    enable = lib.mkEnableOption "power management";

    powerProfilesDaemon = {
      enable = lib.mkEnableOption "power-profiles-daemon" // {
        default = true;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.power-profiles-daemon.enable = cfg.powerProfilesDaemon.enable;
  };
}
