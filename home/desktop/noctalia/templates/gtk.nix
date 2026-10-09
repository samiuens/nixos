{ config, lib, ... }:

let
  enabled = config.smi.desktop.noctalia.enable;
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
