{
  lib,
  pkgs,
  userConfig,
  ...
}:

let
  cfg = userConfig.programs.editor.zed or { };
in
{
  config = lib.mkIf (cfg.enable or false) {
    home.packages = [ pkgs.zed-editor ];
  };
}
