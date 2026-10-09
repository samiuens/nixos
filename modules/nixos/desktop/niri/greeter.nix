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
  shellGreeter = cfg.displayManager == "shell";
in
{
  options.smi.desktop.niri.displayManager = lib.mkOption {
    type = lib.types.enum [
      "shell"
      "gdm"
    ];
    default = "shell";
    description = "Display manager used to start Niri sessions; `shell` uses the greeter of the selected shell.";
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib.mkIf (shellGreeter && cfg.shell == "noctalia") {
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
      })

      (lib.mkIf (shellGreeter && cfg.shell == "dms") {
        services.displayManager = {
          defaultSession = "niri";

          dms-greeter = {
            enable = true;
            compositor = {
              name = "niri";
              customConfig = ''
                input {
                    keyboard {
                        xkb {
                            layout "${keyboard.layout}"
                            variant "${keyboard.variant}"
                        }
                    }
                }

                cursor {
                    xcursor-theme "${cursor.name}"
                    xcursor-size ${toString cursor.size}
                }

                hotkey-overlay {
                    skip-at-startup
                }
              '';
            };
          };
        };
      })

      (lib.mkIf shellGreeter {
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
