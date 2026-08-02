{
  lib,
  pkgs,
  userConfig,
  ...
}:

let
  cfg = userConfig.programs.sync.nextcloud-client or { };
in
{
  config = lib.mkIf (cfg.enable or false) {
    home.packages = [ pkgs.nextcloud-client ];
  };
}
