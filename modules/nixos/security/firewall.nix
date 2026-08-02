{
  lib,
  config,
  ...
}:

let
  cfg = config.smi.security;
in
{
  options.smi.security = {
    enable = lib.mkEnableOption "security defaults";

    firewall = {
      enable = lib.mkEnableOption "firewall" // {
        default = true;
      };

      allowedTCPPorts = lib.mkOption {
        type = lib.types.listOf lib.types.port;
        default = [ ];
        description = "TCP ports allowed through the firewall.";
      };

      allowedUDPPorts = lib.mkOption {
        type = lib.types.listOf lib.types.port;
        default = [ ];
        description = "UDP ports allowed through the firewall.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = {
      enable = cfg.firewall.enable;
      inherit (cfg.firewall) allowedTCPPorts allowedUDPPorts;
    };
  };
}
