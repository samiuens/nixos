{
  lib,
  config,
  ...
}:

let
  cfg = config.smi.boot.plymouth;
in
{
  options.smi.boot.plymouth = {
    enable = lib.mkEnableOption "Plymouth boot splash screen";

    theme = lib.mkOption {
      type = lib.types.str;
      default = "bgrt";
      description = "Plymouth theme to use during boot.";
    };
  };

  config = lib.mkIf cfg.enable {
    boot = {
      plymouth = {
        enable = true;
        inherit (cfg) theme;
      };

      initrd.systemd.enable = true;

      consoleLogLevel = 3;
      initrd.verbose = false;
      kernelParams = [
        "quiet"
        "udev.log_level=3"
        "rd.udev.log_level=3"
      ];
    };
  };
}
