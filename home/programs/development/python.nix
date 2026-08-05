{
  lib,
  pkgs,
  userConfig,
  ...
}:

let
  cfg = userConfig.programs.development.python or { };
in
{
  config = lib.mkIf (cfg.enable or false) {
    home.packages = [ pkgs.python3 ];
  };
}
