{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.smi.services.netbird;
in
{
  options.smi.services.netbird = {
    enable = lib.mkEnableOption "NetBird service, CLI, and GUI";
  };

  config = lib.mkIf cfg.enable {
    services.netbird.enable = true;
    environment.systemPackages = [ pkgs.netbird-ui ];
  };
}
