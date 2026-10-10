{
  config,
  lib,
  pkgs,
  userConfig,
  ...
}:

let
  smiLib = import ../../../../lib { inherit lib; };

  enabled = config.smi.desktop.noctalia.enable && (userConfig.programs.shell.tmux.enable or false);

  tmuxTheme = smiLib.mkTmuxTheme pkgs;

  fallback = pkgs.writeText "noctalia-tmux.conf" tmuxTheme.static;

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

    xdg.configFile."noctalia/templates/tmux.conf".text = tmuxTheme.template;

    home.activation.seedNoctaliaTmuxTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      theme_file="${config.xdg.configHome}/tmux/noctalia.conf"
      if [[ ! -e "$theme_file" ]]; then
        run install -Dm644 ${fallback} "$theme_file"
      fi
    '';
  };
}
