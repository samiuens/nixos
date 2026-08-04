{
  config,
  lib,
  niriDisplayManager,
  pkgs,
  userConfig,
  ...
}:

let
  cfg = config.smi.desktop.noctalia;
  enabled = userConfig.desktop.niri.enable or false;
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
    builtinTemplateIds = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Noctalia built-in template identifiers enabled by application integrations.";
    };

    userTemplates = lib.mkOption {
      type = lib.types.attrsOf (lib.types.attrsOf lib.types.str);
      default = { };
      description = "Noctalia user templates keyed by application identifier.";
    };
  };

  config = lib.mkIf enabled {
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
