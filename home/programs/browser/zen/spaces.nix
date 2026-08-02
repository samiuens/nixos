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
      spacesForce = true;
      spaces = {
        "Personal" = {
          id = "b0b21938-b3e1-4d42-8766-b5c10368b80d";
          position = 1000;
          icon = "chrome://browser/skin/zen-icons/selectable/people.svg";
          container = 1;
        };
      };
    };
  };
}
