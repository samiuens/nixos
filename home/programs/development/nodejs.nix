{
  lib,
  pkgs,
  userConfig,
  ...
}:

let
  cfg = userConfig.programs.development.nodejs or { };
in
{
  config = lib.mkIf (cfg.enable or false) {
    home.packages = [ pkgs.nodejs ];
  };
}
