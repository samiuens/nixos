{
  config,
  lib,
  pkgs,
  userConfig,
  ...
}:

let
  enabled = userConfig.desktop.niri.enable or false;
  fallback = pkgs.writeText "noctalia-niri.kdl" ''
    // Initial fallback; Noctalia's built-in Niri template replaces this file.
    layout {
        focus-ring {
            active-color "#cba6f7"
            inactive-color "#585b70"
        }
    }
  '';
in
{
  config = lib.mkIf enabled {
    smi.desktop.noctalia.builtinTemplateIds = [ "niri" ];
    smi.desktop.niri.extraConfig = lib.mkAfter ''
      include "noctalia.kdl"
    '';

    home.activation.seedNoctaliaNiriTemplate = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      template_file="${config.xdg.configHome}/niri/noctalia.kdl"
      if [[ ! -e "$template_file" ]]; then
        run install -Dm644 ${fallback} "$template_file"
      fi
    '';
  };
}
