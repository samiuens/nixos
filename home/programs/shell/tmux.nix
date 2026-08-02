{
  lib,
  pkgs,
  userConfig,
  ...
}:

let
  cfg = userConfig.programs.shell.tmux or { };
  enabled = name: cfg.plugins.${name}.enable or false;

  tmuxGitStatus = pkgs.writeShellApplication {
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

  statusConfig =
    if (cfg.statusPosition or "bottom") == "hidden" then
      "set -g status off"
    else
      ''
        set -g status on
        set -g status-position ${cfg.statusPosition or "bottom"}
      '';
in
{
  config = lib.mkIf (cfg.enable or false) (
    lib.mkMerge [
      {
        assertions = [
          {
            assertion = !(cfg.autoAttach or false) || (userConfig.programs.terminal.ghostty.enable or false);
            message = "Automatic tmux attachment requires Ghostty to be enabled.";
          }
          {
            assertion = !(enabled "continuum") || enabled "resurrect";
            message = "The tmux Continuum plugin requires Resurrect to be enabled.";
          }
        ];

        programs.tmux = {
          enable = true;
          baseIndex = 1;
          clock24 = true;
          escapeTime = 10;
          focusEvents = true;
          historyLimit = 100000;
          keyMode = cfg.keyMode or "emacs";
          mouse = true;
          prefix = cfg.prefix or "C-b";
          shell = lib.getExe pkgs.fish;
          terminal = "tmux-256color";

          plugins =
            lib.optional (enabled "resurrect") {
              plugin = pkgs.tmuxPlugins.resurrect;
              extraConfig = "set -g @resurrect-capture-pane-contents 'off'";
            }
            ++ lib.optional (enabled "continuum") {
              plugin = pkgs.tmuxPlugins.continuum;
              extraConfig = ''
                set -g @continuum-restore 'on'
                set -g @continuum-save-interval '15'
              '';
            }
            ++ lib.optional (enabled "sessionx") {
              plugin = pkgs.tmuxPlugins.tmux-sessionx;
              extraConfig = "set -g @sessionx-bind 's'";
            };

          extraConfig = ''
            set -g renumber-windows on
            set -g set-clipboard on
            set -as terminal-features ',xterm-ghostty:RGB:clipboard:focus'

            setw -g automatic-rename on
            set -g set-titles on
            set -g set-titles-string '#S:#I:#W'

            unbind '%'
            unbind '"'
            bind '|' split-window -h -c '#{pane_current_path}'
            bind '-' split-window -v -c '#{pane_current_path}'
            bind c new-window -c '#{pane_current_path}'

            bind h select-pane -L
            bind j select-pane -D
            bind k select-pane -U
            bind l select-pane -R
            bind -r H resize-pane -L 5
            bind -r J resize-pane -D 5
            bind -r K resize-pane -U 5
            bind -r L resize-pane -R 5

            bind r source-file ~/.config/tmux/tmux.conf \; display-message 'tmux configuration reloaded'

            bind -T copy-mode-vi v send-keys -X begin-selection
            bind -T copy-mode-vi C-v send-keys -X rectangle-toggle
            bind -T copy-mode-vi y send-keys -X copy-selection-and-cancel

            ${statusConfig}
            set -g status-interval 5
            set -g status-style 'bg=#111111,fg=#777777'
            set -g status-left-length 40
            set -g status-left '#[fg=#7aa2f7,bold] #S #[fg=#777777,bg=#111111,nobold]'
            set -g window-status-separator ' '
            set -g window-status-format '#[fg=#777777]○ #W'
            set -g window-status-current-format '#[fg=#7aa2f7,bold]● #W'
            set -g status-right-length 80
            set -g status-right '#{?client_prefix,#[fg=#e0af68]prefix ,}#[fg=#bb9af7]#(${lib.getExe tmuxGitStatus} #{q:pane_current_path}) #[fg=#777777]%H:%M '

            set -g pane-border-style 'fg=#333333'
            set -g pane-active-border-style 'fg=#7aa2f7'
            set -g message-style 'bg=#111111,fg=#d8d8d8'
            set -g mode-style 'bg=#7aa2f7,fg=#111111'
          '';
        };
      }

      (lib.mkIf (cfg.autoAttach or false) {
        programs.ghostty.settings.command = "${lib.getExe pkgs.tmux} new-session -A -s ${cfg.defaultSession or "main"}";
      })
    ]
  );
}
