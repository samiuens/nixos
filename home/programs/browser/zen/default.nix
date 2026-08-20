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

      # Install the upstream .app untouched on darwin so Team ID based
      # integrations keep working: 1Password, iCloud Passwords, Touch ID,
      # Gatekeeper. Already the flake's default; pinned here because flipping it
      # to "wrapped" silently breaks those.
      # https://github.com/0xc000022070/zen-browser-flake/issues/82
      darwin.packageMode = "signed";
    };
  };
}
