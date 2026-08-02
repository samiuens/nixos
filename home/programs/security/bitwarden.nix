{
  lib,
  pkgs,
  userConfig,
  ...
}:

let
  cfg = userConfig.programs.security.bitwarden or { };
in
{
  config = lib.mkIf (cfg.enable or false) {
    home.packages = [ pkgs.bitwarden-desktop ];
  };
}
