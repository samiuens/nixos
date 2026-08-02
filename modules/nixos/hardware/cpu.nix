{
  lib,
  config,
  ...
}:

let
  cfg = config.smi.hardware.cpu;
in
{
  options.smi.hardware.cpu = {
    enable = lib.mkEnableOption "CPU hardware support";

    vendor = lib.mkOption {
      type = lib.types.enum [ "amd" ];
      default = "amd";
      description = "CPU vendor to configure. Only AMD is implemented currently.";
    };

    microcode = {
      enable = lib.mkEnableOption "CPU microcode updates" // {
        default = true;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    hardware.cpu.amd.updateMicrocode = lib.mkIf (cfg.vendor == "amd") cfg.microcode.enable;
  };
}
