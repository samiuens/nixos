{
  config,
  lib,
  pkgs,
  userConfig,
  ...
}:

let
  enabled =
    (userConfig.desktop.niri.enable or false) && (userConfig.programs.shell.tmux.enable or false);

  gitStatus = pkgs.writeShellApplication {
    name = "tmux-git-status";
    runtimeInputs = [ pkgs.git ];
    text = ''
      directory="''${1:-}"

      if ! git -C "$directory" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        exit 0
      fi

      branch=$(
        git -C "$directory" symbolic-ref --quiet --short HEAD 2>/dev/null \
          || git -C "$directory" rev-parse --short HEAD 2>/dev/null
      ) || exit 0

      if test -n "$(git -C "$directory" status --porcelain=v1 2>/dev/null)"; then
        printf ' %s *' "$branch"
      else
        printf ' %s' "$branch"
      fi
    '';
  };

  fallback = pkgs.writeText "noctalia-tmux.conf" ''
    set -g status-style 'bg=#333333,fg=#777777'
    set -g status-left '#[fg=#7aa2f7,bold] #S #[fg=#777777,bg=#333333,nobold]'
    set -g window-status-format '#[fg=#777777]○ #W'
    set -g window-status-current-format '#[fg=#7aa2f7,bold]● #W'
    set -g status-right '#{?client_prefix,#[fg=#e0af68]prefix ,}#[fg=#bb9af7]#(${lib.getExe gitStatus} #{q:pane_current_path}) #[fg=#777777]%H:%M '

    set -g pane-border-style 'fg=#333333'
    set -g pane-active-border-style 'fg=#7aa2f7'
    set -g message-style 'bg=#111111,fg=#d8d8d8'
    set -g mode-style 'bg=#7aa2f7,fg=#111111'
  '';

  reload = pkgs.writeShellApplication {
    name = "reload-noctalia-tmux-theme";
    runtimeInputs = [ pkgs.tmux ];
    text = ''
      if tmux list-sessions >/dev/null 2>&1; then
        tmux source-file "${config.xdg.configHome}/tmux/noctalia.conf"
      fi
    '';
  };
in
{
  config = lib.mkIf enabled {
    smi.desktop.noctalia.userTemplates.tmux = {
      input_path = "${config.xdg.configHome}/noctalia/templates/tmux.conf";
      output_path = "${config.xdg.configHome}/tmux/noctalia.conf";
      post_hook = lib.getExe reload;
    };

    programs.tmux.extraConfig = lib.mkAfter ''
      source-file -q ~/.config/tmux/noctalia.conf
    '';

    xdg.configFile."noctalia/templates/tmux.conf".text = ''
      set -g status-style 'bg={{colors.surface_variant.default.hex}},fg={{colors.outline.default.hex}}'
      set -g status-left '#[fg={{colors.primary.default.hex}},bold] #S #[fg={{colors.outline.default.hex}},bg={{colors.surface_variant.default.hex}},nobold]'
      set -g window-status-format '#[fg={{colors.outline.default.hex}}]○ #W'
      set -g window-status-current-format '#[fg={{colors.primary.default.hex}},bold]● #W'
      set -g status-right '#{?client_prefix,#[fg={{colors.tertiary.default.hex}}]prefix ,}#[fg={{colors.secondary.default.hex}}]#(${lib.getExe gitStatus} #{q:pane_current_path}) #[fg={{colors.outline.default.hex}}]%H:%M '

      set -g pane-border-style 'fg={{colors.outline.default.hex}}'
      set -g pane-active-border-style 'fg={{colors.primary.default.hex}}'
      set -g message-style 'bg={{colors.surface.default.hex}},fg={{colors.on_surface.default.hex}}'
      set -g mode-style 'bg={{colors.primary.default.hex}},fg={{colors.on_primary.default.hex}}'
    '';

    home.activation.seedNoctaliaTmuxTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      theme_file="${config.xdg.configHome}/tmux/noctalia.conf"
      if [[ ! -e "$theme_file" ]]; then
        run install -Dm644 ${fallback} "$theme_file"
      fi
    '';
  };
}
