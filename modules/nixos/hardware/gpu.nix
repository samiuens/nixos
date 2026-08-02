{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.smi.hardware.gpu;
in
{
  options.smi.hardware.gpu = {
    enable = lib.mkEnableOption "GPU hardware support";

    vendor = lib.mkOption {
      type = lib.types.enum [ "amd" ];
      default = "amd";
      description = "GPU vendor to configure. Only AMD is implemented currently.";
    };

    enable32Bit = lib.mkEnableOption "32-bit graphics drivers for Wine and games";

    loadInInitrd = lib.mkEnableOption "loading the AMDGPU kernel module in initrd";

    opencl = {
      enable = lib.mkEnableOption "AMD OpenCL support";
    };

    firmware = {
      enable = lib.mkEnableOption "explicit AMD GPU linux-firmware package";
    };

    overdrive = {
      enable = lib.mkEnableOption "AMDGPU overdrive mode for LACT tuning";

      ppfeaturemask = lib.mkOption {
        type = lib.types.str;
        default = "0xfffd7fff";
        description = "AMDGPU ppfeaturemask kernel option used when overdrive is enabled.";
      };
    };

    lact = {
      enable = lib.mkEnableOption "LACT AMDGPU controller" // {
        default = true;
      };

      settings = lib.mkOption {
        type = lib.types.attrs;
        default = { };
        description = "LACT daemon settings.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    hardware = lib.mkIf (cfg.vendor == "amd") {
      graphics = {
        enable = true;
        inherit (cfg) enable32Bit;
      };

      amdgpu = {
        initrd.enable = cfg.loadInInitrd;
        opencl.enable = cfg.opencl.enable;
        overdrive = {
          enable = cfg.overdrive.enable;
          inherit (cfg.overdrive) ppfeaturemask;
        };
      };

      firmware = lib.mkIf cfg.firmware.enable [ pkgs.linux-firmware ];
    };

    services.lact = lib.mkIf (cfg.vendor == "amd") {
      enable = cfg.lact.enable;
      inherit (cfg.lact) settings;
    };
  };
}
