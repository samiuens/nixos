{
  lib,
  pkgs,
  userConfig,
  ...
}:

let
  cfg = userConfig.programs.development.glab or { };
in
{
  config = lib.mkIf (cfg.enable or false) {
    home.packages = [ pkgs.glab ];
  };
}
