{
  config,
  lib,
  ...
}:

let
  cfg = config.smi.services.tailscale;
in
{
  options.smi.services.tailscale = {
    enable = lib.mkEnableOption "Tailscale service, CLI, and GUI";
  };

  config = lib.mkIf cfg.enable {
    smi.system.homebrew.extraCasks = [ "tailscale-app" ];
  };
}
