{
  config,
  lib,
  pkgs,
  userConfig,
  ...
}:

let
  enabled =
    (userConfig.desktop.niri.enable or false) && (userConfig.programs.terminal.ghostty.enable or false);
  fallback = pkgs.writeText "noctalia-ghostty-theme" ''
    background = 111111
    foreground = d8d8d8
    selection-background = 333333
    selection-foreground = ffffff
  '';
in
{
  config = lib.mkIf enabled {
    smi.desktop.noctalia.builtinTemplateIds = [ "ghostty" ];
    programs.ghostty.settings.theme = "noctalia";

    home.activation.seedNoctaliaGhosttyTheme =
      lib.hm.dag.entryBetween [ "onFilesChange" ] [ "writeBoundary" ]
        ''
          theme_file="${config.xdg.configHome}/ghostty/themes/noctalia"
          if [[ ! -e "$theme_file" ]]; then
            run install -Dm644 ${fallback} "$theme_file"
          fi
        '';
  };
}
