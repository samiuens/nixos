{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.smi.packages.btrfs-assistant;
in
{
  options.smi.packages.btrfs-assistant = {
    enable = lib.mkEnableOption "Btrfs Assistant";
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.smi.hardware.filesystem.root == "btrfs";
        message = "smi.packages.btrfs-assistant requires a Btrfs root filesystem.";
      }
      {
        assertion = config.smi.services.snapper.enable;
        message = "smi.packages.btrfs-assistant requires Snapper to be enabled.";
      }
    ];

    environment.systemPackages = [ pkgs.btrfs-assistant ];
  };
}
