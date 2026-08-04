{
  config,
  lib,
  ...
}:

let
  cfg = config.smi.desktop.niri;
  cursor = config.smi.desktop.shared.cursor;
  keyboard = config.smi.environment.keyboard;
in
{
  options.smi.desktop.niri.noctaliaGreeter.enable = lib.mkEnableOption "Noctalia Greeter" // {
    default = true;
  };

  config = lib.mkIf (cfg.enable && cfg.noctaliaGreeter.enable) {
    programs.noctalia-greeter = {
      enable = true;

      settings = {
        session.default = "niri";

        cursor = {
          theme = cursor.name;
          inherit (cursor) size;
          path = "${cursor.package}/share/icons";
        };

        keyboard = {
          inherit (keyboard) layout variant;
        };
      };
    };

    # Noctalia Greeter runs through greetd, so avoid starting a competing
    # display manager.
    services.displayManager.gdm.enable = lib.mkForce false;
  };
}
