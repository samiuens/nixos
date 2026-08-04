{
  lib,
  userConfig,
  ...
}:

let
  cfg = userConfig.services.flatpak or { };
in
{
  config = lib.mkIf (cfg.enable or false) {
    services.flatpak = {
      enable = true;
      inherit (cfg) packages;
      update.auto = {
        enable = cfg.autoUpdate.enable && cfg.packages != [ ];
        inherit (cfg.autoUpdate) onCalendar;
      };
    };
  };
}
