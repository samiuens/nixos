{
  lib,
  pkgs,
  userConfig,
  ...
}:

let
  cfg = userConfig.programs.development.codex or { };
  codex = pkgs.callPackage ../../../packages/codex-bin.nix { };
in
{
  config = lib.mkIf (cfg.enable or false) {
    home.packages = [ codex ];
  };
}
