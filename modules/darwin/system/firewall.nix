{
  lib,
  config,
  ...
}:

let
  cfg = config.smi.system.firewall;
in
{
  options.smi.system.firewall = {
    enable = lib.mkEnableOption "the built-in macOS application firewall";

    stealthMode = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to ignore probes to closed ports, including pings.";
    };

    blockAllIncoming = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to block all incoming connections.";
    };

    allowSigned = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether built-in software may accept incoming connections.";
    };

    allowSignedApp = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether signed downloaded software may accept connections.";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.applicationFirewall = {
      enable = true;
      enableStealthMode = cfg.stealthMode;
      inherit (cfg) blockAllIncoming allowSigned allowSignedApp;
    };
  };
}
