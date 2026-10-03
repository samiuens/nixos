{
  lib,
  pkgs,
  userConfig,
  ...
}:

let
  smiLib = import ../../../lib { inherit lib; };
  cfg = userConfig.programs.media.ente-photos or { };
  catalogueKey = "programs.media.ente-photos";
  entry = (smiLib.appCatalogue pkgs).${catalogueKey};
  useNixPackage = smiLib.preferNixPackage pkgs catalogueKey;
in
{
  config = lib.mkIf (cfg.enable or false) {
    home.packages = lib.optional useNixPackage entry.package;
  };
}
