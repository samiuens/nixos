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

  # nixpkgs has no darwin build of ghostty. There the app comes from a Homebrew
  # cask and Home Manager only manages its configuration file.
  useNixPackage = smiLib.nixUsable pkgs pkgs.ghostty;

  # gtk-* are Linux-only ghostty options.
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
