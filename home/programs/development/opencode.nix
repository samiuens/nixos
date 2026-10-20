{
  lib,
  pkgs,
  userConfig,
  ...
}:

let
  smiLib = import ../../../lib { inherit lib; };
  cfg = userConfig.programs.development.opencode or { };
  catalogueKey = "programs.development.opencode";
  entry = (smiLib.appCatalogue pkgs).${catalogueKey};
  useNixPackage = smiLib.preferNixPackage pkgs catalogueKey;

  # Pinned so a plugin release lands with a commit, not on the next launch.
  claudePlugin = "@openchamber/opencode-claude@1.4.2";

  baseSettings = {
    plugins = [ claudePlugin ];

    # Last match wins: block every provider, then allow the plugin's.
    policies = [
      {
        action = "provider.use";
        resource = "*";
        effect = "deny";
      }
      {
        action = "provider.use";
        resource = "claude-code";
        effect = "allow";
      }
    ];
  };
in
{
  config = lib.mkIf (cfg.enable or false) {
    programs.opencode = {
      enable = true;

      # Homebrew installs it on darwin; the config is still written.
      package = if useNixPackage then entry.package else null;

      settings = baseSettings;
    };
  };
}
