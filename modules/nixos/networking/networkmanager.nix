{
  lib,
  config,
  ...
}:

let
  cfg = config.smi.networking.networkmanager;
in
{
  options.smi.networking.networkmanager = {
    enable = lib.mkEnableOption "NetworkManager";
  };

  config = lib.mkIf cfg.enable {
    networking.networkmanager.enable = true;
  };
}
