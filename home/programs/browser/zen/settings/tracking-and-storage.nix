{
  lib,
  userConfig,
  ...
}:

let
  zenCfg = userConfig.programs.browser.zen or { };
  cfg = zenCfg.betterfox or { };

  settings = {
    # Tracking protection
    "browser.contentblocking.category" = "strict";
    "browser.download.start_downloads_in_tmp_dir" = true;
    "browser.uitour.enabled" = false;
    "privacy.globalprivacycontrol.enabled" = true;

    # OCSP, certificates, and HPKP
    "security.OCSP.enabled" = 0;
    "privacy.antitracking.isolateContentScriptResources" = true;
    "security.csp.reporting.enabled" = false;

    # SSL and TLS
    "security.ssl.treat_unsafe_negotiation_as_broken" = true;
    "browser.xul.error_pages.expert_bad_cert" = true;
    "security.tls.enable_0rtt_data" = false;

    # Disk avoidance
    "browser.cache.disk.enable" = false;
    "browser.privatebrowsing.forceMediaMemoryCache" = true;
    "media.memory_cache_max_size" = 65536;
    "browser.sessionstore.interval" = 60000;

    # Shutdown and sanitizing
    "privacy.history.custom" = true;
  };
in
{
  config = lib.mkIf ((zenCfg.enable or false) && (cfg.enable or false)) {
    programs.zen-browser.profiles.default.settings = lib.mapAttrs (_: lib.mkDefault) settings;
  };
}
