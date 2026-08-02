{
  lib,
  config,
  ...
}:

let
  cfg = config.smi.system.host;
in
{
  options.smi.system.host = {
    enable = lib.mkEnableOption "host identity";

    name = lib.mkOption {
      type = lib.types.str;
      description = "Hostname for this machine. Set this explicitly per host.";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.hostName = cfg.name;
  };
}
