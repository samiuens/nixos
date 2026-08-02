{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.smi.boot.kernel;

  kernelPackages = {
    default = pkgs.linuxPackages;
    latest = pkgs.linuxPackages_latest;
    zen = pkgs.linuxPackages_zen;
    hardened = pkgs.linuxPackages_hardened;
  };
in
{
  options.smi.boot.kernel = {
    enable = lib.mkEnableOption "kernel configuration";

    package = lib.mkOption {
      type = lib.types.enum (builtins.attrNames kernelPackages);
      default = "default";
      description = "Kernel package set to use.";
    };

    parameters = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Kernel command line parameters.";
    };

    modules = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Kernel modules to load during stage 2 boot.";
    };

    blacklistedModules = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Kernel modules to blacklist.";
    };

    extraModulePackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Additional kernel module packages to build for the selected kernel.";
    };

    initrd = {
      availableModules = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Kernel modules available in initrd.";
      };

      modules = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Kernel modules loaded in initrd.";
      };
    };

    sysctl = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Kernel sysctl settings.";
    };
  };

  config = lib.mkIf cfg.enable {
    boot = {
      inherit (cfg) extraModulePackages;

      kernelPackages = kernelPackages.${cfg.package};
      kernelParams = cfg.parameters;
      kernelModules = cfg.modules;
      blacklistedKernelModules = cfg.blacklistedModules;

      initrd = {
        availableKernelModules = cfg.initrd.availableModules;
        kernelModules = cfg.initrd.modules;
      };
    };

    boot.kernel.sysctl = cfg.sysctl;
  };
}
