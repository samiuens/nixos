{
  lib,
  pkgs,
  userConfig,
  ...
}:

let
  cfg = userConfig.programs.security.sops or { };
in
{
  config = lib.mkIf (cfg.enable or false) {
    home.packages = [ pkgs.sops ];
  };
}
