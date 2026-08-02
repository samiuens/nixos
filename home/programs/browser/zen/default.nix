{
  config,
  lib,
  userConfig,
  ...
}:

let
  cfg = userConfig.programs.browser.zen or { };
in
{
  config = lib.mkIf (cfg.enable or false) {
    # Keep legacy lookups on ~/.zen pointed at Zen's current configuration directory.
    home.file.".zen".source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/zen";

    programs.zen-browser = {
      enable = true;
      setAsDefaultBrowser = cfg.setAsDefaultBrowser or false;
    };
  };
}
