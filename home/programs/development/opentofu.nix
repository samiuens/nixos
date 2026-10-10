{
  lib,
  pkgs,
  userConfig,
  ...
}:

let
  cfg = userConfig.programs.development.opentofu or { };
in
{
  config = lib.mkIf (cfg.enable or false) {
    home.packages = [ pkgs.opentofu ];
  };
}
