{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.smi.boot.limine;
in
{
  options.smi.boot.limine = {
    enable = lib.mkEnableOption "Limine bootloader";

    maxGenerations = lib.mkOption {
      type = lib.types.nullOr lib.types.int;
      default = 20;
      description = "Generations shown in the boot menu.";
    };

    editor = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to allow editing boot entries from the Limine menu.";
    };

    windows = {
      enable = lib.mkEnableOption "a Windows entry in the Limine boot menu";

      partitionUuid = lib.mkOption {
        type = lib.types.str;
        description = "PARTUUID of the Windows EFI partition.";
        example = "3da67cbf-ba14-44c6-a5cf-5a9951594208";
      };
    };

    secureBoot = {
      enable = lib.mkEnableOption "signing the Limine EFI binary for Secure Boot";

      autoGenerateKeys = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to generate missing Secure Boot keys.";
      };

      autoEnrollKeys = {
        enable = lib.mkEnableOption "automatic enrollment of generated Secure Boot keys";

        extraArgs = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [
            "--microsoft"
            "--firmware-builtin"
          ];
          description = "Extra sbctl enroll arguments.";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.sbctl ];

    boot.loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = false;
      grub.enable = false;

      limine = {
        enable = true;
        efiInstallAsRemovable = false;
        enableEditor = cfg.editor;
        inherit (cfg) maxGenerations;

        extraEntries = lib.optionalString cfg.windows.enable ''
          /Windows
            protocol: efi
            path: uuid(${cfg.windows.partitionUuid}):/EFI/Microsoft/Boot/bootmgfw.efi
        '';

        secureBoot = {
          inherit (cfg.secureBoot) enable autoGenerateKeys;
          inherit (cfg.secureBoot) autoEnrollKeys;
        };
      };
    };
  };
}
