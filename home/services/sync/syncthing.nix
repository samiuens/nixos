{ lib, userConfig, ... }:

let
  cfg = userConfig.services.sync.syncthing or { };
in
{
  config = lib.mkIf (cfg.enable or false) {
    services.syncthing = {
      enable = true;
    }
    // lib.optionalAttrs (cfg.tray.enable or false) {
      tray.enable = true;
    };
  };
}
