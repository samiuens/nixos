{
  lib,
  pkgs,
  userConfig,
  ...
}:

let
  smiLib = import ../../../lib { inherit lib; };
  cfg = userConfig.programs.sync.nextcloud-client or { };

  # Unavailable in nixpkgs on darwin; installed from a Homebrew cask there instead.
  useNixPackage = smiLib.nixUsable pkgs pkgs.nextcloud-client;
in
{
  config = lib.mkIf (cfg.enable or false) {
    home.packages = lib.optional useNixPackage pkgs.nextcloud-client;
  };
}
