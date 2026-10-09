{
  config,
  lib,
  ...
}:

let
  enabled = config.smi.desktop.noctalia.enable;
in
{
  config = lib.mkIf enabled {
    smi.desktop.noctalia.builtinTemplateIds = [ "qt" ];

    qt = {
      enable = true;
      platformTheme.name = "qtct";

      qt5ctSettings.Appearance = {
        color_scheme_path = "${config.xdg.configHome}/qt5ct/colors/noctalia.conf";
        custom_palette = true;
        style = "Fusion";
      };

      qt6ctSettings.Appearance = {
        color_scheme_path = "${config.xdg.configHome}/qt6ct/colors/noctalia.conf";
        custom_palette = true;
        style = "Fusion";
      };
    };
  };
}
