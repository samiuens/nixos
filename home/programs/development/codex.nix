{
  lib,
  pkgs,
  userConfig,
  ...
}:

let
  smiLib = import ../../../lib { inherit lib; };
  cfg = userConfig.programs.development.codex or { };

  catalogueKey = "programs.development.codex";

  # Taken from the catalogue rather than named again here, so the package and its
  # Homebrew cask cannot drift apart.
  entry = (smiLib.appCatalogue pkgs).${catalogueKey};

  useNixPackage = smiLib.preferNixPackage pkgs catalogueKey;
in
{
  config = lib.mkIf (cfg.enable or false) {
    home.packages = lib.optional useNixPackage entry.package;
  };
}
