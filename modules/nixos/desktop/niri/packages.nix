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
        description = "Cursor theme name used by Niri and Noctalia Greeter.";
      };

      size = lib.mkOption {
        type = lib.types.ints.positive;
        default = 24;
        description = "Cursor size used by Niri and Noctalia Greeter.";
      };
    };

    noctaliaGreeter.enable = lib.mkEnableOption "Noctalia Greeter" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    programs = {
      niri.enable = true;

      noctalia = {
        enable = true;
        recommendedServices.enable = true;
      };

      noctalia-greeter = lib.mkIf cfg.noctaliaGreeter.enable {
        enable = true;

        settings = {
          session.default = "niri";

          cursor = {
            theme = cfg.cursor.name;
            size = cfg.cursor.size;
            path = "${cfg.cursor.package}/share/icons";
          };
        };
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

    # Noctalia Greeter runs through greetd. Keep the GNOME session installed,
    # but do not start GDM when the greeter is enabled.
    services.displayManager.gdm.enable = lib.mkIf cfg.noctaliaGreeter.enable (lib.mkForce false);

  };
}
