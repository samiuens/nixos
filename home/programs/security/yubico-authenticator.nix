{
  lib,
  pkgs,
  userConfig,
  ...
}:

let
  smiLib = import ../../../lib { inherit lib; };
  cfg = userConfig.programs.security.yubico-authenticator or { };

  useNixPackage = smiLib.nixUsable pkgs pkgs.yubioath-flutter;
in
{
  config = lib.mkIf (cfg.enable or false) {
    home.packages = lib.optional useNixPackage pkgs.yubioath-flutter;
  };
}
