{
  config,
  lib,
  pkgs,
  ...
}:

let
  usersCfg = config.smi.system.users;
  enabledUsers = lib.filterAttrs (name: _: builtins.elem name usersCfg.enabledUsers) usersCfg.users;

  desktopEnabled = config.smi.desktop.gnome.enable || config.smi.desktop.niri.enable;
  alternativeTerminalEnabled = lib.any (
    user:
    (user.programs.terminal.alacritty.enable or false)
    || (user.programs.terminal.ghostty.enable or false)
  ) (lib.attrValues enabledUsers);
in
{
  options.smi.desktop.alternativeTerminalEnabled = lib.mkOption {
    type = lib.types.bool;
    default = alternativeTerminalEnabled;
    readOnly = true;
    internal = true;
    description = "Whether a user picked a terminal outside the desktop.";
  };

  config = lib.mkMerge [
    (lib.mkIf desktopEnabled {
      documentation.nixos.enable = false;
    })

    (lib.mkIf config.smi.desktop.alternativeTerminalEnabled {
      environment.gnome.excludePackages = [
        pkgs.gnome-console
        pkgs.gnome-terminal
      ];
      programs.gnome-terminal.enable = false;
    })
  ];
}
