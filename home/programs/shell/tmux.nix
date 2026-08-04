{
  lib,
  pkgs,
  userConfig,
  ...
}:

let
  cfg = userConfig.programs.shell.tmux or { };
  enabled = name: cfg.plugins.${name}.enable or false;

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
            set -g status-left-length 40
            set -g window-status-separator ' '
            set -g status-right-length 80

          '';
        };
      }

      (lib.mkIf (cfg.autoAttach or false) {
        programs.ghostty.settings.command = "${lib.getExe pkgs.tmux} new-session -A -s ${cfg.defaultSession or "main"}";
      })
    ]
  );
}
