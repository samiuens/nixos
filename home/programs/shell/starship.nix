{ lib, userConfig, ... }:

let
  cfg = userConfig.programs.shell.starship or { };
in
{
  config = lib.mkIf (cfg.enable or false) {
    programs.starship = {
      enable = true;
    }
    // lib.optionalAttrs ((cfg.settings or { }) != { }) {
      inherit (cfg) settings;
    };
  };
}
