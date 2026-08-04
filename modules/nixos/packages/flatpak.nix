{
  config,
  lib,
  ...
}:

let
  cfg = config.smi.packages.flatpak;
  packageType = with lib.types; either str attrs;
in
{
  options.smi.packages.flatpak = {
    enable = lib.mkEnableOption "declarative system-wide Flatpak management";

    packages = lib.mkOption {
      type = lib.types.listOf packageType;
      default = [ ];
      description = "Flatpak applications to install system-wide.";
    };

    autoUpdate = {
      enable = lib.mkEnableOption "automatic Flatpak updates" // {
        default = true;
      };

      onCalendar = lib.mkOption {
        type = lib.types.str;
        default = "weekly";
        description = "Systemd calendar expression for Flatpak updates.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.flatpak = {
      enable = true;
      inherit (cfg) packages;
      update.auto = {
        enable = cfg.autoUpdate.enable && cfg.packages != [ ];
        inherit (cfg.autoUpdate) onCalendar;
      };
    };
  };
}
