{
  config,
  lib,
  niriDisplayManager,
  niriShell,
  pkgs,
  userConfig,
  ...
}:

let
  cfg = config.smi.desktop.noctalia;
  tomlFormat = pkgs.formats.toml { };

  userSettings = builtins.fromTOML (builtins.readFile ./config.toml);
  switchUser = pkgs.writeShellScript "noctalia-switch-user" ''
    set -eu

    noctalia msg session lock
    ${lib.getExe' pkgs.glib "gdbus"} call \
      --system \
      --dest org.gnome.DisplayManager \
      --object-path /org/gnome/DisplayManager/LocalDisplayFactory \
      --method org.gnome.DisplayManager.LocalDisplayFactory.CreateTransientDisplay
  '';
  sessionActions = [
    {
      action = "lock";
      shortcut = "1";
    }
    {
      action = "command";
      command = "${switchUser}";
      glyph = "switch-horizontal";
      label = "Switch User";
      shortcut = "2";
    }
    {
      action = "logout";
      shortcut = "3";
    }
    {
      action = "lock_and_suspend";
      shortcut = "4";
    }
    {
      action = "reboot";
      shortcut = "5";
    }
    {
      action = "shutdown";
      shortcut = "6";
      variant = "destructive";
    }
  ];
  sessionSettings =
    userSettings.shell.session
    // lib.optionalAttrs (niriDisplayManager == "gdm") {
      actions = sessionActions;
    };
  greeterSyncSettings = userSettings.shell.greeter_sync // {
    auto_sync = niriDisplayManager == "noctalia";
  };
  pluginSettings = {
    enabled = userConfig.desktop.niri.noctalia.plugins or [ ];
  };
  templateSettings = {
    enable_builtin_templates = true;
    builtin_ids = lib.unique cfg.builtinTemplateIds;
    user = cfg.userTemplates;
  };
in
{
  options.smi.desktop.noctalia = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = (userConfig.desktop.niri.enable or false) && niriShell == "noctalia";
      readOnly = true;
      internal = true;
      description = "Whether Noctalia Shell runs in this user's Niri session.";
    };

    builtinTemplateIds = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Noctalia templates enabled by integrations.";
    };

    userTemplates = lib.mkOption {
      type = lib.types.attrsOf (lib.types.attrsOf lib.types.str);
      default = { };
      description = "Noctalia user templates keyed by application identifier.";
    };
  };

  config = lib.mkIf cfg.enable {
    smi.desktop.niri.extraConfig = ''
      include "noctalia-shell.kdl"
    '';

    xdg.configFile."niri/noctalia-shell.kdl".text = ''
      spawn-at-startup "noctalia"

      window-rule {
          match app-id="dev.noctalia.Noctalia"
          open-floating true
          default-column-width { fixed 1080; }
          default-window-height { fixed 920; }
      }

      layer-rule {
          match namespace="^noctalia-backdrop"
          place-within-backdrop true
      }

      binds {
          Mod+Space hotkey-overlay-title="Open the Application Launcher" { spawn-sh "noctalia msg panel-toggle launcher"; }
          Mod+S hotkey-overlay-title="Open the Control Center" { spawn-sh "noctalia msg panel-toggle control-center"; }
          Mod+Comma hotkey-overlay-title="Open Noctalia Settings" { spawn-sh "noctalia msg settings-toggle"; }
          Alt+Tab hotkey-overlay-title="Switch Windows" { spawn-sh "noctalia msg window-switcher"; }
          Super+Alt+L hotkey-overlay-title="Lock the Session" { spawn-sh "noctalia msg session lock"; }

          XF86AudioRaiseVolume allow-when-locked=true { spawn-sh "noctalia msg volume-up"; }
          XF86AudioLowerVolume allow-when-locked=true { spawn-sh "noctalia msg volume-down"; }
          XF86AudioMute allow-when-locked=true { spawn-sh "noctalia msg volume-mute"; }
          XF86AudioMicMute allow-when-locked=true { spawn-sh "noctalia msg mic-mute"; }
          XF86MonBrightnessUp allow-when-locked=true { spawn-sh "noctalia msg brightness-up"; }
          XF86MonBrightnessDown allow-when-locked=true { spawn-sh "noctalia msg brightness-down"; }
      }
    '';

    xdg.configFile."noctalia/config.toml".source = tomlFormat.generate "noctalia-config.toml" (
      userSettings
      // {
        plugins = pluginSettings;
        shell = userSettings.shell // {
          greeter_sync = greeterSyncSettings;
          session = sessionSettings;
        };
        theme = userSettings.theme // {
          templates = templateSettings;
        };
      }
    );
  };
}
