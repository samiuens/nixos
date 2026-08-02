{
  lib,
  config,
  ...
}:

let
  cfg = config.smi.hardware.filesystem;
in
{
  options.smi.hardware.filesystem = {
    enable = lib.mkEnableOption "filesystem support";

    root = lib.mkOption {
      type = lib.types.enum [
        "btrfs"
        "ext4"
      ];
      default = "ext4";
      description = "Root filesystem type supported by this module.";
    };

    efi = lib.mkOption {
      type = lib.types.enum [ "vfat" ];
      default = "vfat";
      description = "EFI system partition filesystem type.";
    };
  };

  config = lib.mkIf cfg.enable {
    boot = {
      supportedFilesystems = [
        cfg.root
        cfg.efi
      ];

      initrd.supportedFilesystems = [ cfg.root ];
    };
  };
}
