{
  lib,
  config,
  ...
}:

let
  cfg = config.smi.services.printing;
in
{
  options.smi.services.printing = {
    enable = lib.mkEnableOption "printing support";

    drivers = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Additional printer driver packages.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.printing = {
      enable = true;
      inherit (cfg) drivers;
    };
  };
}
