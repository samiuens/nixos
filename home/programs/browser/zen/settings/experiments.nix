{
  lib,
  userConfig,
  ...
}:

let
  zenCfg = userConfig.programs.browser.zen or { };
  cfg = zenCfg.betterfox or { };

  settings = {
    # Experiments
    "app.shield.optoutstudies.enabled" = false;
    "app.normandy.enabled" = false;
    "app.normandy.api_url" = "";

    # Crash reports
    "breakpad.reportURL" = "";
    "browser.tabs.crashReporting.sendReport" = false;
  };
in
{
  config = lib.mkIf ((zenCfg.enable or false) && (cfg.enable or false)) {
    programs.zen-browser.profiles.default.settings = lib.mapAttrs (_: lib.mkDefault) settings;
  };
}
