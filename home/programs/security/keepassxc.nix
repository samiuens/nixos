{
  lib,
  pkgs,
  userConfig,
  ...
}:

let
  cfg = userConfig.programs.security.keepassxc or { };
in
{
  config = lib.mkIf (cfg.enable or false) {
    home.packages = [
      pkgs.keepassxc
    ];
  };
}
