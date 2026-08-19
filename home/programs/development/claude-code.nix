{
  lib,
  pkgs,
  userConfig,
  ...
}:

let
  smiLib = import ../../../lib { inherit lib; };
  cfg = userConfig.programs.development.claude-code or { };

  # Prebuilt Linux-only binary; on darwin the tool is installed through Homebrew.
  claude-code = pkgs.callPackage ../../../packages/claude-code-bin.nix { };
  useNixPackage = smiLib.nixUsable pkgs claude-code;
in
{
  config = lib.mkIf (cfg.enable or false) {
    home.packages = lib.optional useNixPackage claude-code;
  };
}
