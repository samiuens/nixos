{
  lib,
  userConfig,
  ...
}:

let
  smiLib = import ../../../../lib { inherit lib; };
  cfg = userConfig.programs.browser.zen or { };

  # Numbered alongside the spaces that reference them, so a space and its
  # cookie jar cannot disagree about which container is which.
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
