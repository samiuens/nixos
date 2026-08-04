{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.smi.desktop.shared.appearance;
in
{
  options.smi.desktop.shared.appearance = {
    enable = lib.mkEnableOption "shared desktop appearance assets";

    packages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ pkgs.adwaita-icon-theme ];
      description = "Theme packages installed independently of a desktop session.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment = {
      pathsToLink = [ "/share/icons" ];
      systemPackages = cfg.packages;
    };
  };
}
