{ lib, userConfig, ... }:

let
  cfg = userConfig.programs.editor.vscodium or { };
in
{
  config = lib.mkIf (cfg.enable or false) {
    programs.vscodium = {
      enable = true;
    }
    // lib.optionalAttrs ((cfg.profiles or { }) != { }) {
      inherit (cfg) profiles;
    };
  };
}
