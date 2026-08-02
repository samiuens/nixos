{
  lib,
  config,
  ...
}:

let
  cfg = config.smi.environment.timezone;
in
{
  options.smi.environment.timezone = {
    enable = lib.mkEnableOption "timezone configuration";

    timeZone = lib.mkOption {
      type = lib.types.str;
      default = "Europe/Berlin";
      description = "System timezone.";
    };

    hardwareClockInLocalTime = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to keep the hardware clock in local time for Windows dual booting.";
    };
  };

  config = lib.mkIf cfg.enable {
    time = {
      inherit (cfg) hardwareClockInLocalTime timeZone;
    };
  };
}
