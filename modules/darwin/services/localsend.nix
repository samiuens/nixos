{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.smi.services.localsend;
in
{
  options.smi.services.localsend = {
    enable = lib.mkEnableOption "LocalSend";
  };

  config = lib.mkIf cfg.enable {
    # NixOS opens port 53317 for this. macOS filters per application instead, so
    # the application firewall asks once on first launch and there is no port to
    # declare here.
    environment.systemPackages = [ pkgs.localsend ];
  };
}
