{
  lib,
  pkgs,
  userConfig,
  ...
}:

let
  cfg = userConfig.programs.development.uv or { };
in
{
  config = lib.mkIf (cfg.enable or false) {
    home.packages = [ pkgs.uv ];
  };
}
