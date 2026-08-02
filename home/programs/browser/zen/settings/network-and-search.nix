{
  lib,
  userConfig,
  ...
}:

let
  zenCfg = userConfig.programs.browser.zen or { };
  cfg = zenCfg.betterfox or { };

  settings = {
    # Speculative loading
    "network.http.speculative-parallel-limit" = 0;
    "network.dns.disablePrefetch" = true;
    "network.dns.disablePrefetchFromHTTPS" = true;
    "browser.urlbar.speculativeConnect.enabled" = false;
    "browser.places.speculativeConnect.enabled" = false;
    "network.prefetch-next" = false;

    # Search and URL bar
    "browser.urlbar.trimHttps" = true;
    "browser.urlbar.untrimOnUserInteraction.featureGate" = true;
    "browser.search.separatePrivateDefault.ui.enabled" = true;
    "browser.search.suggest.enabled" = false;
    "browser.urlbar.quicksuggest.enabled" = false;
    "browser.urlbar.groupLabels.enabled" = false;
    "browser.formfill.enable" = false;
    "network.IDN_show_punycode" = true;

    # HTTPS-only mode
    "dom.security.https_only_mode" = true;
    "dom.security.https_only_mode_error_page_user_suggestions" = true;

    # Passwords
    "signon.formlessCapture.enabled" = false;
    "signon.privateBrowsingCapture.enabled" = false;
    "network.auth.subresource-http-auth-allow" = 1;
    "editor.truncate_user_pastes" = false;
  };
in
{
  config = lib.mkIf ((zenCfg.enable or false) && (cfg.enable or false)) {
    programs.zen-browser.profiles.default.settings = lib.mapAttrs (_: lib.mkDefault) settings;
  };
}
