{ lib, userConfig, ... }:

let
  cfg = userConfig.services.security.gpg-agent or { };
in
{
  config = lib.mkIf (cfg.enable or false) {
    services.gpg-agent = {
      enable = true;
    }
    // lib.optionalAttrs ((cfg.defaultCacheTtl or null) != null) {
      inherit (cfg) defaultCacheTtl;
    }
    // lib.optionalAttrs ((cfg.maxCacheTtl or null) != null) {
      inherit (cfg) maxCacheTtl;
    };
  };
}
