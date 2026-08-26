{
  lib,
  userConfig,
  ...
}:

let
  smiLib = import ../../../../lib { inherit lib; };
  cfg = userConfig.programs.browser.zen or { };

  # Resolved together with the containers, so a space's `container` name is
  # turned into the same number containers.nix writes out.
  resolved = smiLib.zenProfile cfg;
in
{
  config = lib.mkIf (cfg.enable or false) {
    programs.zen-browser.profiles.default = {
      spacesForce = true;
      inherit (resolved) spaces;
    };
  };
}
