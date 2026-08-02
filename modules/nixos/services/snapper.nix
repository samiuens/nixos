{
  config,
  lib,
  ...
}:

let
  cfg = config.smi.services.snapper;
  smiLib = import ../../../lib { inherit lib; };

  accessSettings = {
    ALLOW_USERS = cfg.allowedUsers;
    SYNC_ACL = true;
  };
in
{
  options.smi.services.snapper = {
    enable = lib.mkEnableOption "Btrfs snapshots with Snapper";

    allowedUsers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = smiLib.getAdminUsers config.smi.system.users.users;
      description = "Users allowed to manage the configured Snapper snapshots.";
    };

    snapshotInterval = lib.mkOption {
      type = lib.types.str;
      default = "hourly";
      description = "Systemd calendar expression for timeline snapshots.";
    };

    cleanupInterval = lib.mkOption {
      type = lib.types.str;
      default = "1d";
      description = "Interval between Snapper cleanup runs.";
    };

    snapshotRootOnBoot = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to create a root snapshot during each boot.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.smi.hardware.filesystem.root == "btrfs";
        message = "smi.services.snapper requires a Btrfs root filesystem.";
      }
    ];

    services.snapper = {
      inherit (cfg) cleanupInterval snapshotInterval snapshotRootOnBoot;
      persistentTimer = true;

      configs = {
        root = accessSettings // {
          SUBVOLUME = "/";
          TIMELINE_CREATE = false;
          NUMBER_CLEANUP = true;
          NUMBER_LIMIT = 10;
          NUMBER_LIMIT_IMPORTANT = 5;
        };

        home = accessSettings // {
          SUBVOLUME = "/home";
          TIMELINE_CREATE = true;
          TIMELINE_CLEANUP = true;
          TIMELINE_LIMIT_HOURLY = 10;
          TIMELINE_LIMIT_DAILY = 7;
          TIMELINE_LIMIT_WEEKLY = 4;
          TIMELINE_LIMIT_MONTHLY = 6;
          TIMELINE_LIMIT_QUARTERLY = 0;
          TIMELINE_LIMIT_YEARLY = 0;
        };
      };
    };

    services.locate.pruneNames = [
      ".bzr"
      ".cache"
      ".git"
      ".hg"
      ".snapshots"
      ".svn"
    ];
  };
}
