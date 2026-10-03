{
  lib,
  userConfig,
  ...
}:

let
  smiLib = import ../../../../lib { inherit lib; };
  cfg = userConfig.programs.browser.zen or { };

  resolved = smiLib.zenProfile cfg;
in
{
  config = lib.mkIf (cfg.enable or false) {
    programs.zen-browser.profiles.default = {
      containersForce = true;
      inherit (resolved) containers;
    };
  };
}
