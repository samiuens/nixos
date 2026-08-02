{ lib, userConfig, ... }:

let
  cfg = userConfig.programs.terminal.ghostty or { };
in
{
  config = lib.mkIf (cfg.enable or false) {
    programs.ghostty = {
      enable = true;
    }
    // lib.optionalAttrs ((cfg.settings or { }) != { }) {
      inherit (cfg) settings;
    };
  };
}
