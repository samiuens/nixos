{
  lib,
  userConfig,
  ...
}:

let
  zenCfg = userConfig.programs.browser.zen or { };
  cfg = zenCfg.betterfox or { };

  settings = {
    # Mozilla UI
    "extensions.getAddons.showPane" = false;
    "extensions.htmlaboutaddons.recommendations.enabled" = false;
    "browser.discovery.enabled" = false;
    "browser.shell.checkDefaultBrowser" = false;
    "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
    "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = false;
    "browser.preferences.moreFromMozilla" = false;
    "browser.aboutConfig.showWarning" = false;
    "browser.startup.homepage_override.mstone" = "ignore";
    "browser.aboutwelcome.enabled" = false;
    "browser.profiles.enabled" = true;

    # Theme adjustments
    "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
    "browser.compactmode.show" = true;
    "browser.privateWindowSeparation.enabled" = false;
  };
in
{
  config = lib.mkIf ((zenCfg.enable or false) && (cfg.enable or false)) {
    programs.zen-browser.profiles.default.settings = lib.mapAttrs (_: lib.mkDefault) settings;
  };
}
