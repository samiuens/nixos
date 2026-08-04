{
  lib,
  pkgs,
  userConfig,
  ...
}:

let
  cfg = userConfig.programs.browser.chrome or { };
in
{
  config = lib.mkIf (cfg.enable or false) {
    home.packages = [ pkgs.google-chrome ];
  };
}
