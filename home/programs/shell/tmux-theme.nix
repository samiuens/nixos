{
  lib,
  pkgs,
  userConfig,
  ...
}:

let
  smiLib = import ../../../lib { inherit lib; };

  inherit (pkgs.stdenv.hostPlatform) isDarwin;

  enabled = isDarwin && (userConfig.programs.shell.tmux.enable or false);

  gitStatus = smiLib.mkTmuxGitStatus pkgs;

  colours = {
    surface = "#111111";
    surfaceVariant = "#333333";
    onSurface = "#d8d8d8";
    outline = "#777777";
    primary = "#7aa2f7";
    onPrimary = "#111111";
    secondary = "#bb9af7";
    tertiary = "#e0af68";
  };
in
{
  config = lib.mkIf enabled {
    programs.tmux.extraConfig = lib.mkAfter ''
      set -g status-style 'bg=${colours.surfaceVariant},fg=${colours.outline}'
      set -g status-left '#[fg=${colours.primary},bold] #S #[fg=${colours.outline},bg=${colours.surfaceVariant},nobold]'
      set -g window-status-format '#[fg=${colours.outline}]○ #W'
      set -g window-status-current-format '#[fg=${colours.primary},bold]● #W'
      set -g status-right '#{?client_prefix,#[fg=${colours.tertiary}]prefix ,}#[fg=${colours.secondary}]#(${lib.getExe gitStatus} #{q:pane_current_path}) #[fg=${colours.outline}]%H:%M '

      set -g pane-border-style 'fg=${colours.surfaceVariant}'
      set -g pane-active-border-style 'fg=${colours.primary}'
      set -g message-style 'bg=${colours.surface},fg=${colours.onSurface}'
      set -g mode-style 'bg=${colours.primary},fg=${colours.onPrimary}'
    '';
  };
}
