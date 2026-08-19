{
  lib,
  pkgs,
  userConfig,
  ...
}:

let
  smiLib = import ../../../lib { inherit lib; };
  cfg = userConfig.programs.development.codex or { };

  # Prebuilt Linux-only binary; on darwin the tool is installed through Homebrew.
  codex = pkgs.callPackage ../../../packages/codex-bin.nix { };
  useNixPackage = smiLib.nixUsable pkgs codex;
in
{
  config = lib.mkIf (cfg.enable or false) {
    home.packages = lib.optional useNixPackage codex;
  };
}
