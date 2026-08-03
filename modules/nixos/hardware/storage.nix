{
  lib,
  config,
  ...
}:

let
  cfg = config.smi.hardware.storage;
in
{
  options.smi.hardware.storage = {
    enable = lib.mkEnableOption "storage defaults";

    btrfsScrub = {
      enable = lib.mkEnableOption "periodic Btrfs scrubbing" // {
        default = config.smi.hardware.filesystem.root == "btrfs";
      };

      interval = lib.mkOption {
        type = lib.types.str;
        default = "monthly";
        description = "Systemd calendar expression for periodic Btrfs scrubbing.";
      };

      fileSystems = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "/" ];
        description = "Btrfs filesystem mount points to scrub periodically.";
      };
    };

    smartd = {
      enable = lib.mkEnableOption "SMART and NVMe health monitoring" // {
        default = true;
      };
    };

    trim = {
      enable = lib.mkEnableOption "periodic SSD TRIM" // {
        default = true;
      };

      interval = lib.mkOption {
        type = lib.types.str;
        default = "weekly";
        description = "Systemd calendar expression for periodic SSD TRIM.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !cfg.btrfsScrub.enable || config.smi.hardware.filesystem.root == "btrfs";
        message = "smi.hardware.storage.btrfsScrub requires a Btrfs root filesystem.";
      }
    ];

    services = {
      btrfs.autoScrub = {
        enable = cfg.btrfsScrub.enable;
        inherit (cfg.btrfsScrub) fileSystems interval;
      };

      fstrim = {
        enable = cfg.trim.enable;
        inherit (cfg.trim) interval;
      };

      smartd.enable = cfg.smartd.enable;
    };
  };
}
