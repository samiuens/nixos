{
  lib,
  config,
  ...
}:

let
  cfg = config.smi.hardware.wifi;
in
{
  options.smi.hardware.wifi = {
    enable = lib.mkEnableOption "WiFi hardware support";

    firmware = {
      enable = lib.mkEnableOption "redistributable wireless firmware" // {
        default = true;
      };
    };

    regulatoryDatabase = {
      enable = lib.mkEnableOption "wireless regulatory database" // {
        default = true;
      };
    };

    intelAx200 = {
      enable = lib.mkEnableOption "Intel AX200 support";

      workaround = {
        enable = lib.mkEnableOption "conservative Intel AX200 iwlwifi workarounds";

        disableBluetoothCoexistence = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Set iwlwifi bt_coex_active=0.";
        };

        disablePowerSave = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Set iwlwifi power_save=0.";
        };

        useSoftwareCrypto = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Set iwlwifi swcrypto=1.";
        };

        disable11ax = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Set iwlwifi disable_11ax=1.";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    hardware = {
      enableRedistributableFirmware = cfg.firmware.enable;
      wirelessRegulatoryDatabase = cfg.regulatoryDatabase.enable;
    };

    boot = lib.mkIf cfg.intelAx200.enable {
      kernelModules = [ "iwlwifi" ];
      extraModprobeConfig = lib.mkIf cfg.intelAx200.workaround.enable ''
        options iwlwifi ${
          lib.concatStringsSep " " (
            lib.optional cfg.intelAx200.workaround.disableBluetoothCoexistence "bt_coex_active=0"
            ++ lib.optional cfg.intelAx200.workaround.disablePowerSave "power_save=0"
            ++ lib.optional cfg.intelAx200.workaround.useSoftwareCrypto "swcrypto=1"
            ++ lib.optional cfg.intelAx200.workaround.disable11ax "disable_11ax=1"
          )
        }
      '';
    };
  };
}
