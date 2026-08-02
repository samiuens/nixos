{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.smi.desktop.gnome;
in
{
  options.smi.desktop.gnome.enable = lib.mkEnableOption "GNOME desktop";

  config = lib.mkIf cfg.enable {
    services = {
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;

      gnome = {
        core-apps.enable = false;
        core-developer-tools.enable = false;
        games.enable = false;
      };
    };

    documentation.nixos.enable = false;

    environment = {
      systemPackages = [
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
      gnome.excludePackages = [ pkgs.gnome-tour ];
    };

    programs.gnome-disks.enable = true;

    services.xserver.excludePackages = [ pkgs.xterm ];
  };
}
