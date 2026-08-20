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
      description = ''
        Whether to drop probes for closed ports instead of answering them, which
        also stops this host replying to pings.
      '';
    };

    blockAllIncoming = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to block every incoming connection apart from those needed for
        basic internet services. This overrides the allowances below, so sharing
        services and peer-to-peer applications stop accepting connections.
      '';
    };

    allowSigned = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether built-in software may accept incoming connections.";
    };

    allowSignedApp = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Whether downloaded software signed by a valid certificate authority may
        accept incoming connections without prompting.
      '';
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
