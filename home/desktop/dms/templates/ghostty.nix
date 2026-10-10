{
  config,
  lib,
  pkgs,
  userConfig,
  ...
}:

let
  enabled = config.smi.desktop.dms.enable && (userConfig.programs.terminal.ghostty.enable or false);
  fallback = pkgs.writeText "dms-ghostty-theme" ''
    background = 111111
    foreground = d8d8d8
    selection-background = 333333
    selection-foreground = ffffff
  '';
in
{
  config = lib.mkIf enabled {
    # DMS writes this theme from its built-in Ghostty matugen template.
    programs.ghostty.settings.theme = "dankcolors";

    home.activation.seedDmsGhosttyTheme =
      lib.hm.dag.entryBetween [ "onFilesChange" ] [ "writeBoundary" ]
        ''
          theme_file="${config.xdg.configHome}/ghostty/themes/dankcolors"
          if [[ ! -e "$theme_file" ]]; then
            run install -Dm644 ${fallback} "$theme_file"
          fi
        '';
  };
}
