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
    enable = lib.mkEnableOption "Tailscale service and CLI";
  };

  config = lib.mkIf cfg.enable {
    services.tailscale.enable = true;
  };
}
