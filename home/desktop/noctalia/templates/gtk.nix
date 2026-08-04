{ lib, userConfig, ... }:

let
  enabled = userConfig.desktop.niri.enable or false;
in
{
  config = lib.mkIf enabled {
    smi.desktop.noctalia.builtinTemplateIds = [
      "gtk3"
      "gtk4"
    ];

    gtk = {
      enable = true;

      gtk3.extraCss = ''
        @import url("noctalia.css");
      '';

      gtk4.extraCss = ''
        @import url("noctalia.css");
      '';
    };
  };
}
