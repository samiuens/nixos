{
  config,
  lib,
  pkgs,
  userConfig,
  ...
}:

let
  smiLib = import ../../../lib { inherit lib; };

  # Noctalia and DMS generate the theme from their colours; their modules are
  # not imported on Darwin.
  enabled =
    !(config.smi.desktop.noctalia.enable or false)
    && !(config.smi.desktop.dms.enable or false)
    && (userConfig.programs.shell.tmux.enable or false);
in
{
  config = lib.mkIf enabled {
    programs.tmux.extraConfig = lib.mkAfter (smiLib.mkTmuxTheme pkgs).static;
  };
}
