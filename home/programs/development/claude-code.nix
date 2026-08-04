{
  lib,
  pkgs,
  userConfig,
  ...
}:

let
  cfg = userConfig.programs.development.claude-code or { };
  claude-code = pkgs.callPackage ../../../packages/claude-code-bin.nix { };
in
{
  config = lib.mkIf (cfg.enable or false) {
    home.packages = [ claude-code ];
  };
}
