{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.smi.desktop.shared.applications;
in
{
  options.smi.desktop.shared.applications = {
    enable = lib.mkEnableOption "shared desktop applications";

    packages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [
        pkgs.gnome-calculator
        pkgs.gnome-console
        pkgs.gnome-control-center
        pkgs.gnome-disk-utility
        pkgs.gnome-system-monitor
        pkgs.gnome-text-editor
        pkgs.loupe
        pkgs.nautilus
        pkgs.papers
      ];
      description = "Graphical applications installed independently of a desktop session.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = cfg.packages;
    programs.gnome-disks.enable = true;
  };
}
