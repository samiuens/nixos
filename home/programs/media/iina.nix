{
  lib,
  pkgs,
  userConfig,
  ...
}:

let
  smiLib = import ../../../lib { inherit lib; };
  cfg = userConfig.programs.media.iina or { };
  catalogueKey = "programs.media.iina";
  entry = (smiLib.appCatalogue pkgs).${catalogueKey};
  useNixPackage = smiLib.preferNixPackage pkgs catalogueKey;
in
{
  config = lib.mkIf (cfg.enable or false) {
    home.packages = lib.optional useNixPackage entry.package;
  };
}
