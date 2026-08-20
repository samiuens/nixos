{
  lib,
  pkgs,
  userConfig,
  ...
}:

let
  smiLib = import ../../../lib { inherit lib; };
  cfg = userConfig.programs.editor.zed or { };

  useNixPackage = smiLib.preferNixPackage pkgs "programs.editor.zed";
in
{
  config = lib.mkIf (cfg.enable or false) {
    home.packages = lib.optional useNixPackage pkgs.zed-editor;
  };
}
