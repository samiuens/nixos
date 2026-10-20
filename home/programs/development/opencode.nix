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

  # Pre-5 ids the Claude Code CLI may still report; listing one it lacks is harmless.
  legacyModels = [
    "claude-haiku-4-5"
    "claude-haiku-4-5-20251001"
    "claude-opus-4-1"
    "claude-opus-4-5"
    "claude-opus-4-6"
    "claude-opus-4-6[1m]"
    "claude-opus-4-7"
    "claude-opus-4-8"
    "claude-sonnet-4-5"
    "claude-sonnet-4-6"
    "claude-sonnet-4-6[1m]"
  ];

  baseSettings = {
    model = "claude-code/claude-opus-5-5[1m]";
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

    providers.claude-code.models = lib.genAttrs legacyModels (_: {
      disabled = true;
    });
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
