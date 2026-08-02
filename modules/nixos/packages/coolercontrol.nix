{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.smi.packages.coolercontrol;
in
{
  options.smi.packages.coolercontrol = {
    enable = lib.mkEnableOption "CoolerControl";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      liquidctl
      lm_sensors
    ];

    programs.coolercontrol.enable = true;
  };
}
