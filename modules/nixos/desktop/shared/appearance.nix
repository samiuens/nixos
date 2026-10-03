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
      description = "Desktop-independent theme packages.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment = {
      pathsToLink = [ "/share/icons" ];
      systemPackages = cfg.packages;
    };
  };
}
