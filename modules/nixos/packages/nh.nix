{
  lib,
  config,
  ...
}:

let
  cfg = config.smi.packages.nh;
in
{
  options.smi.packages.nh = {
    enable = lib.mkEnableOption "nh";

    flake = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Default flake path used by nh.";
    };

    clean = {
      enable = lib.mkEnableOption "periodic cleanup with nh" // {
        default = true;
      };

      dates = lib.mkOption {
        type = lib.types.str;
        default = "weekly";
        description = "Systemd calendar expression for nh clean.";
      };

      extraArgs = lib.mkOption {
        type = lib.types.str;
        default = "--keep 5 --keep-since 14d";
        description = "Extra arguments passed to nh clean all.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.nh = {
      enable = true;
      inherit (cfg) flake;
      clean = {
        inherit (cfg.clean) enable dates extraArgs;
      };
    };
  };
}
