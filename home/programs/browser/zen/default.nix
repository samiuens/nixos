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
    home.file.".zen".source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/zen";

    programs.zen-browser = {
      enable = true;
      setAsDefaultBrowser = cfg.setAsDefaultBrowser or false;

      # Wrapping breaks Team ID integrations (1Password, Touch ID, Gatekeeper).
      # https://github.com/0xc000022070/zen-browser-flake/issues/82
      darwin.packageMode = "signed";
    };
  };
}
