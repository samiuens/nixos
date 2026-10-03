{
  lib,
  pkgs,
  userConfig,
  ...
}:

let
  smiLib = import ../../../lib { inherit lib; };
  cfg = userConfig.programs.terminal.ghostty or { };

  inherit (pkgs.stdenv.hostPlatform) isDarwin;

  useNixPackage = smiLib.nixUsable pkgs pkgs.ghostty;

  settings = lib.filterAttrs (name: _: !(isDarwin && lib.hasPrefix "gtk-" name)) (
    (cfg.settings or { }) // lib.optionalAttrs isDarwin (cfg.darwinSettings or { })
  );
in
{
  config = lib.mkIf (cfg.enable or false) {
    programs.ghostty = {
      enable = true;
    }
    // lib.optionalAttrs (!useNixPackage) {
      package = null;
    }
    // lib.optionalAttrs (settings != { }) {
      inherit settings;
    };
  };
}
