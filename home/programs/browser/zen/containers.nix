{
  lib,
  userConfig,
  ...
}:

let
  cfg = userConfig.programs.browser.zen or { };
in
{
  config = lib.mkIf (cfg.enable or false) {
    programs.zen-browser.profiles.default = {
      containersForce = true;
      containers = {
        Personal = {
          color = "blue";
          icon = "circle";
          id = 1;
        };
      };
    };
  };
}
