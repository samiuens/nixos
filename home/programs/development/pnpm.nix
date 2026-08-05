{
  lib,
  pkgs,
  userConfig,
  ...
}:

let
  cfg = userConfig.programs.development.pnpm or { };
in
{
  config = lib.mkIf (cfg.enable or false) {
    home.packages = [ pkgs.pnpm ];
  };
}
