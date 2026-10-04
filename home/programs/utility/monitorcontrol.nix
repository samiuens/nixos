{
  lib,
  pkgs,
  userConfig,
  ...
}:

let
  smiLib = import ../../../lib { inherit lib; };
  cfg = userConfig.programs.utility.monitorcontrol or { };

  catalogueKey = "programs.utility.monitorcontrol";

  entry = (smiLib.appCatalogue pkgs).${catalogueKey};

  useNixPackage = smiLib.preferNixPackage pkgs catalogueKey;
in
{
  config = lib.mkIf (cfg.enable or false) {
    home.packages = lib.optional useNixPackage entry.package;
  };
}
