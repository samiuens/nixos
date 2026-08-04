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
      })

      (lib.mkIf (cfg.displayManager == "gdm") {
        programs.noctalia-greeter.enable = lib.mkForce false;
        services.displayManager = {
          defaultSession = "niri";
          gdm.enable = true;
        };

        # GDM launches the command from niri.desktop using its service PATH.
        # niri-session also invokes Bash before entering the user's login shell.
        systemd.services.display-manager.path = [
          config.programs.niri.package
          pkgs.bash
        ];
      })
    ]
  );
}
