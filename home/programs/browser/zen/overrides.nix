{
  lib,
  userConfig,
  ...
}:

let
  cfg = userConfig.programs.browser.zen or { };
in
{
  config = lib.mkIf (cfg.enable or false) {
    # Preferences declared here override Betterfox's defaults.
    programs.zen-browser.profiles.default.settings = lib.mapAttrs (_: lib.mkForce) {
      # Zen specific
      "zen.welcome-screen.seen" = true;
      "zen.workspaces.continue-where-left-off" = true;

      # Firefox general
      "browser.search.suggest.enabled" = true;
      "layout.spellcheckDefault" = 0;
      "signon.firefoxRelay.feature" = "disabled";
      "network.trr.mode" = 3;
      "network.trr.uri" = "https://dns.quad9.net/dns-query";
      "signon.rememberSignons" = false;
      "signon.management.page.breach-alerts.enabled" = false;
      "extensions.formautofill.addresses.enabled" = false;
      "extensions.formautofill.creditCards.enabled" = false;
      "security.webauth.webauthn" = false;
      "browser.contentblocking.category" = "custom";
      "network.cookie.cookieBehavior" = 1;
      "network.cookie.cookieBehavior.pbmode" = 5;
      "privacy.trackingprotection.enabled" = true;
      "privacy.trackingprotection.pbmode.enabled" = true;
      "privacy.trackingprotection.socialtracking.enabled" = true;
      "privacy.socialtracking.block_cookies.enabled" = true;
      "privacy.trackingprotection.emailtracking.enabled" = true;
      "privacy.trackingprotection.emailtracking.pbmode.enabled" = true;
      "privacy.trackingprotection.cryptomining.enabled" = true;
      "privacy.trackingprotection.fingerprinting.enabled" = true;
      "privacy.fingerprintingProtection" = true;
      "privacy.fingerprintingProtection.pbmode" = true;
      "privacy.trackingprotection.allow_list.baseline.enabled" = true;
      "privacy.trackingprotection.allow_list.convenience.enabled" = true;
    };
  };
}
