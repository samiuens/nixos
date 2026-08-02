{
  lib,
  userConfig,
  ...
}:

let
  zenCfg = userConfig.programs.browser.zen or { };
  cfg = zenCfg.betterfox or { };

  settings = {
    # Extensions
    "extensions.enabledScopes" = 5;

    # Headers and referrers
    "network.http.referer.XOriginTrimmingPolicy" = 2;

    # Containers
    "privacy.userContext.ui.enabled" = true;

    # PDF scripting
    "pdfjs.enableScripting" = false;

    # Safe Browsing
    "browser.safebrowsing.downloads.remote.enabled" = false;

    # Mozilla services
    "permissions.default.desktop-notification" = 2;
    "permissions.default.geo" = 2;
    "geo.provider.network.url" = "https://beacondb.net/v1/geolocate";
    "browser.search.update" = false;
    "permissions.manager.defaultsUrl" = "";
    "extensions.getAddons.cache.enabled" = false;
  };
in
{
  config = lib.mkIf ((zenCfg.enable or false) && (cfg.enable or false)) {
    programs.zen-browser.profiles.default.settings = lib.mapAttrs (_: lib.mkDefault) settings;
  };
}
