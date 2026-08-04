{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.smi.desktop.shared.cursor;
in
{
  options.smi.desktop.shared.cursor = {
    enable = lib.mkEnableOption "shared desktop cursor";

    package = lib.mkPackageOption pkgs "adwaita-icon-theme" { };

    name = lib.mkOption {
      type = lib.types.str;
      default = "Adwaita";
      description = "Cursor theme name used by desktop sessions and greeters.";
    };

    size = lib.mkOption {
      type = lib.types.ints.positive;
      default = 24;
      description = "Cursor size used by desktop sessions and greeters.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment = {
      sessionVariables = {
        XCURSOR_THEME = cfg.name;
        XCURSOR_SIZE = toString cfg.size;
      };

      pathsToLink = [ "/share/icons" ];
      systemPackages = [ cfg.package ];
    };
  };
}
