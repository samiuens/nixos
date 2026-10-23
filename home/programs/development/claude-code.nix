{
  lib,
  pkgs,
  hostName,
  osConfig,
  userConfig,
  ...
}:

let
  smiLib = import ../../../lib { inherit lib; };
  cfg = userConfig.programs.development.claude-code or { };

  # A user's own value replaces the shared one as a whole; read both to layer them by key.
  shared = lib.attrByPath [
    "programs"
    "development"
    "claude-code"
  ] { } (osConfig.smi.system.users.shared or { });
  catalogueKey = "programs.development.claude-code";
  entry = (smiLib.appCatalogue pkgs).${catalogueKey};
  useNixPackage = smiLib.preferNixPackage pkgs catalogueKey;

  statusLine = pkgs.writeShellApplication {
    name = "claude-code-statusline";
    runtimeInputs = [ pkgs.jq ];
    text = builtins.readFile ./claude-code/statusline.sh;
  };

  baseSettings = {
    tui = "fullscreen";

    statusLine = {
      type = "command";
      command = lib.getExe statusLine;
    };
  };
in
{
  config = lib.mkIf (cfg.enable or false) {
    home.packages = lib.optional useNixPackage entry.package;

    programs.claude-code = {
      enable = true;
      package = null;

      # Merged into settings.json on activation: declared keys win, and the
      # rest of the file, such as plugins and /config changes, stays.
      mutableSettings = true;
      settings = lib.foldl lib.recursiveUpdate baseSettings [
        (shared.settings or { })
        (cfg.settings or { })
      ];

      # Go into a personal plugin the module generates.
      mcpServers = (shared.mcpServers or { }) // (cfg.mcpServers or { });

      context = smiLib.mkAgentContext {
        inherit hostName;
        inherit (pkgs.stdenv) hostPlatform;
        inherit (userConfig) programs;
        comma = osConfig.smi.packages.comma.enable or false;
      };
    };
  };
}
