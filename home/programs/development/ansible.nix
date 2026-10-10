{
  lib,
  pkgs,
  userConfig,
  ...
}:

let
  cfg = userConfig.programs.development.ansible or { };
in
{
  config = lib.mkIf (cfg.enable or false) {
    home.packages = [ pkgs.ansible ];
  };
}
