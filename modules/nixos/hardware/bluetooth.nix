{
  lib,
  config,
  ...
}:

let
  cfg = config.smi.hardware.bluetooth;
in
{
  options.smi.hardware.bluetooth = {
    enable = lib.mkEnableOption "Bluetooth support";

    powerOnBoot = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to power up the default Bluetooth controller on boot.";
    };

    settings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "BlueZ settings written to /etc/bluetooth/main.conf.";
    };
  };

  config = lib.mkIf cfg.enable {
    hardware.bluetooth = {
      enable = true;
      inherit (cfg) powerOnBoot settings;
    };
  };
}
