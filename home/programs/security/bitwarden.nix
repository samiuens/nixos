{
  lib,
  pkgs,
  userConfig,
  ...
}:

let
  smiLib = import ../../../lib { inherit lib; };
  cfg = userConfig.programs.security.bitwarden or { };

  # The desktop app comes from a Homebrew cask on darwin. The CLI has no cask and
  # stays on nixpkgs everywhere.
  useNixPackage = smiLib.preferNixPackage pkgs "programs.security.bitwarden";
in
{
  config = lib.mkIf (cfg.enable or false) {
    home.packages = lib.optional useNixPackage pkgs.bitwarden-desktop ++ [ pkgs.bitwarden-cli ];
  };
}
