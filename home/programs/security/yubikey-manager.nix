{
  lib,
  pkgs,
  userConfig,
  ...
}:

let
  cfg = userConfig.programs.security.yubikey-manager or { };
in
{
  config = lib.mkIf (cfg.enable or false) {
    home.packages = [ pkgs.yubikey-manager ];
  };
}
