{
  config,
  lib,
  pkgs,
  userConfig,
  ...
}:

let
  smiLib = import ../../../../lib { inherit lib; };
  tomlFormat = pkgs.formats.toml { };

  enabled = config.smi.desktop.dms.enable && (userConfig.programs.shell.tmux.enable or false);

  tmuxTheme = smiLib.mkTmuxTheme pkgs;
  themeFile = "${config.xdg.configHome}/tmux/dms.conf";

  fallback = pkgs.writeText "dms-tmux.conf" tmuxTheme.static;

  reload = pkgs.writeShellApplication {
    name = "reload-dms-tmux-theme";
    runtimeInputs = [ pkgs.tmux ];
    text = ''
      if tmux list-sessions >/dev/null 2>&1; then
        tmux source-file "${themeFile}"
      fi
    '';
  };
in
{
  config = lib.mkIf enabled {
    # DMS adds every matugen config in this directory to its colour generation.
    xdg.configFile."matugen/dms/configs/tmux.toml".source =
      tomlFormat.generate "dms-tmux-matugen.toml"
        {
          templates.smitmux = {
            input_path = pkgs.writeText "dms-tmux-template.conf" tmuxTheme.template;
            output_path = themeFile;
            post_hook = lib.getExe reload;
          };
        };

    programs.tmux.extraConfig = lib.mkAfter ''
      source-file -q ~/.config/tmux/dms.conf
    '';

    home.activation.seedDmsTmuxTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      theme_file="${themeFile}"
      if [[ ! -e "$theme_file" ]]; then
        run install -Dm644 ${fallback} "$theme_file"
      fi
    '';
  };
}
