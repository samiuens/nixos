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
  catalogueKey = "programs.development.claude-code";
  entry = (smiLib.appCatalogue pkgs).${catalogueKey};
  useNixPackage = smiLib.preferNixPackage pkgs catalogueKey;
in
{
  config = lib.mkIf (cfg.enable or false) {
    home.packages = lib.optional useNixPackage entry.package;

    # Only CLAUDE.md is managed; without declared settings the module leaves settings.json alone.
    programs.claude-code = {
      enable = true;
      package = null;

      context = smiLib.mkAgentContext {
        inherit hostName;
        inherit (pkgs.stdenv) hostPlatform;
        inherit (userConfig) programs;
        comma = osConfig.smi.packages.comma.enable or false;
      };
    };
  };
}
