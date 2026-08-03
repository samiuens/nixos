{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.smi.desktop.niri;
in
{
  options.smi.desktop.niri = {
    enable = lib.mkEnableOption "Niri desktop with Noctalia Shell";

    cursor = {
      package = lib.mkPackageOption pkgs "adwaita-icon-theme" { };

      name = lib.mkOption {
        type = lib.types.str;
        default = "Adwaita";
        description = "Cursor theme name used by Niri.";
      };

      size = lib.mkOption {
        type = lib.types.ints.positive;
        default = 24;
        description = "Cursor size used by Niri.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs = {
      niri.enable = true;

      noctalia = {
        enable = true;
        recommendedServices.enable = true;
      };
    };

    environment = {
      sessionVariables = {
        XCURSOR_THEME = cfg.cursor.name;
        XCURSOR_SIZE = toString cfg.cursor.size;
      };

      pathsToLink = [ "/share/icons" ];

      # Niri starts xwayland-satellite on demand for applications that still
      # require X11.
      systemPackages = [
        cfg.cursor.package
        pkgs.xwayland-satellite
      ];
    };
  };
}
