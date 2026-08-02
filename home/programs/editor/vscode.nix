{ lib, userConfig, ... }:

let
  cfg = userConfig.programs.editor.vscode or { };
in
{
  config = lib.mkIf (cfg.enable or false) {
    programs.vscode = {
      enable = true;
    }
    // lib.optionalAttrs ((cfg.profiles or { }) != { }) {
      inherit (cfg) profiles;
    };
  };
}
