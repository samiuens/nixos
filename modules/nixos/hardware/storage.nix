{
  lib,
  config,
  ...
}:

let
  cfg = config.smi.hardware.storage;
in
{
  options.smi.hardware.storage = {
    enable = lib.mkEnableOption "storage defaults";

    trim = {
      enable = lib.mkEnableOption "periodic SSD TRIM" // {
        default = true;
      };

      interval = lib.mkOption {
        type = lib.types.str;
        default = "weekly";
        description = "Systemd calendar expression for periodic SSD TRIM.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.fstrim = {
      enable = cfg.trim.enable;
      inherit (cfg.trim) interval;
    };
  };
}
