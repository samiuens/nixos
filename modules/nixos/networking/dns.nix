{
  lib,
  config,
  ...
}:

let
  cfg = config.smi.networking.dns;
in
{
  options.smi.networking.dns = {
    enable = lib.mkEnableOption "DNS configuration";

    provider = lib.mkOption {
      type = lib.types.enum [ "quad9" ];
      default = "quad9";
      description = "DNS provider to configure. Only Quad9 is implemented currently.";
    };

    protocol = lib.mkOption {
      type = lib.types.enum [ "doh" ];
      default = "doh";
      description = "Encrypted DNS protocol. Only DNS over HTTPS is implemented currently.";
    };

    listenAddress = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1:53";
      description = "Local address and port for the DNS proxy.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.dnscrypt-proxy = lib.mkIf (cfg.provider == "quad9" && cfg.protocol == "doh") {
      enable = true;
      settings = {
        server_names = [ "quad9-doh-ip4-port443-filter-pri" ];
        listen_addresses = [ cfg.listenAddress ];
        ipv6_servers = true;
        require_dnssec = true;
        require_nolog = true;
        require_nofilter = false;
      };
    };

    networking = {
      nameservers = [ "127.0.0.1" ];
      networkmanager.dns = "none";
    };
  };
}
