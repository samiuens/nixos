{
  lib,
  pkgs,
  userConfig,
  ...
}:

let
  cfg = userConfig.programs.communication.signal-desktop or { };
in
{
  config = lib.mkIf (cfg.enable or false) {
    home.packages = [ pkgs.signal-desktop ];
  };
}
