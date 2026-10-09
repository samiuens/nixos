{
  config,
  lib,
  ...
}:

let
  cfg = config.smi.desktop.niri;
in
{
  options.smi.desktop.niri = {
    enable = lib.mkEnableOption "Niri desktop";

    shell = lib.mkOption {
      type = lib.types.enum [
        "noctalia"
        "dms"
      ];
      default = "noctalia";
      description = "Desktop shell started in Niri sessions.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.niri.enable = true;
    services.udisks2.enable = true;
  };
}
