{
  lib,
  config,
  ...
}:

let
  cfg = config.smi.environment.keyboard;
in
{
  options.smi.environment.keyboard = {
    enable = lib.mkEnableOption "keyboard configuration";

    layout = lib.mkOption {
      type = lib.types.str;
      default = "de";
      description = "XKB keyboard layout.";
    };

    variant = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "XKB keyboard variant.";
    };

    consoleKeyMap = lib.mkOption {
      type = lib.types.str;
      default = "de";
      description = "Console keyboard map.";
    };
  };

  config = lib.mkIf cfg.enable {
    console.keyMap = cfg.consoleKeyMap;

    services.xserver.xkb = {
      inherit (cfg) layout variant;
    };
  };
}
