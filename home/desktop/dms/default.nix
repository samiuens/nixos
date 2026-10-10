{
  config,
  lib,
  niriShell,
  userConfig,
  ...
}:

let
  cfg = config.smi.desktop.dms;
  configDir = "${config.xdg.configHome}/DankMaterialShell";
in
{
  options.smi.desktop.dms.enable = lib.mkOption {
    type = lib.types.bool;
    default = (userConfig.desktop.niri.enable or false) && niriShell == "dms";
    readOnly = true;
    internal = true;
    description = "Whether DankMaterialShell runs in this user's Niri session.";
  };

  config = lib.mkIf cfg.enable {
    smi.desktop.niri.extraConfig = ''
      include "dms-shell.kdl"
    '';

    xdg.configFile."niri/dms-shell.kdl".text = ''
      spawn-at-startup "dms" "run"

      layer-rule {
          match namespace="^quickshell$"
          place-within-backdrop true
      }

      binds {
          Mod+Space hotkey-overlay-title="Open the Application Launcher" { spawn "dms" "ipc" "call" "spotlight" "toggle"; }
          Mod+S hotkey-overlay-title="Open the Control Center" { spawn "dms" "ipc" "call" "control-center" "toggle"; }
          Mod+N hotkey-overlay-title="Open the Notification Center" { spawn "dms" "ipc" "call" "notifications" "toggle"; }
          Mod+Comma hotkey-overlay-title="Open DMS Settings" { spawn "dms" "ipc" "call" "settings" "focusOrToggle"; }
          Super+X hotkey-overlay-title="Open the Power Menu" { spawn "dms" "ipc" "call" "powermenu" "toggle"; }
          Super+Alt+L hotkey-overlay-title="Lock the Session" { spawn "dms" "ipc" "call" "lock" "lock"; }

          XF86AudioRaiseVolume allow-when-locked=true { spawn "dms" "ipc" "call" "audio" "increment" "3"; }
          XF86AudioLowerVolume allow-when-locked=true { spawn "dms" "ipc" "call" "audio" "decrement" "3"; }
          XF86AudioMute allow-when-locked=true { spawn "dms" "ipc" "call" "audio" "mute"; }
          XF86AudioMicMute allow-when-locked=true { spawn "dms" "ipc" "call" "audio" "micmute"; }
          XF86MonBrightnessUp allow-when-locked=true { spawn "dms" "ipc" "call" "brightness" "increment" "5" ""; }
          XF86MonBrightnessDown allow-when-locked=true { spawn "dms" "ipc" "call" "brightness" "decrement" "5" ""; }
      }

      // Colors, layout and outputs DMS writes from its settings.
      include optional=true "dms/colors.kdl"
      include optional=true "dms/layout.kdl"
      include optional=true "dms/alttab.kdl"
      include optional=true "dms/outputs.kdl"
    '';

    # DMS rewrites its settings from the GUI, so they are copied instead of
    # linked. Wallpaper and other session state live in ~/.local/state.
    home.activation.seedDmsSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run install -Dm644 ${./settings.json} "${configDir}/settings.json"
    '';
  };
}
