{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.smi.desktop.niri;
  cursor = config.smi.desktop.shared.cursor;
  keyboard = config.smi.environment.keyboard;
in
{
  options.smi.desktop.niri.displayManager = lib.mkOption {
    type = lib.types.enum [
      "noctalia"
      "gdm"
    ];
    default = "noctalia";
    description = "Display manager used to start Niri sessions.";
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib.mkIf (cfg.displayManager == "noctalia") {
        services.displayManager.noctalia-greeter = {
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

        services.displayManager.gdm.enable = lib.mkForce false;
      })

      (lib.mkIf (cfg.displayManager == "gdm") {
        services.displayManager.noctalia-greeter.enable = lib.mkForce false;
        services.displayManager = {
          defaultSession = "niri";
          gdm.enable = true;
        };

        # niri-session runs Bash before the login shell.
        systemd.services.display-manager.path = [
          config.programs.niri.package
          pkgs.bash
        ];
      })
    ]
  );
}
