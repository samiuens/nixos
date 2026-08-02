{
  lib,
  pkgs,
  userConfig,
  ...
}:

let
  cfg = userConfig.programs.browser.firefox or { };
in
{
  config = lib.mkIf (cfg.enable or false) {
    home.packages = [ pkgs.firefox ];
  };
}
