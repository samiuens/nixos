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

  # A user's own `mcpServers` replaces the shared one as a whole; read both to layer them by name.
  shared = lib.attrByPath [
    "programs"
    "development"
    "claude-code"
  ] { } (osConfig.smi.system.users.shared or { });
  catalogueKey = "programs.development.claude-code";
  entry = (smiLib.appCatalogue pkgs).${catalogueKey};
  useNixPackage = smiLib.preferNixPackage pkgs catalogueKey;
in
{
  config = lib.mkIf (cfg.enable or false) {
    home.packages = lib.optional useNixPackage entry.package;

    # Without declared settings the module leaves settings.json alone; MCP
    # servers go into a personal plugin it generates.
    programs.claude-code = {
      enable = true;
      package = null;

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
