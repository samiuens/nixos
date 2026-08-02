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
    programs.zen-browser.profiles.default.mods = [
      "a6335949-4465-4b71-926c-4a52d34bc9c0" # Better Find Bar
      "906c6915-5677-48ff-9bfc-096a02a72379" # Floating Status Bar
      "4ab93b88-151c-451b-a1b7-a1e0e28fa7f8" # No Sidebar Scrollbar
      "c8d9e6e6-e702-4e15-8972-3596e57cf398" # Zen Back Forward
      "58649066-2b6f-4a5b-af6d-c3d21d16fc00" # Private Mode Highlighting
      #"8039de3b-72e1-41ea-83b3-5077cf0f98d1" # Trackpad Animation
    ];
  };
}
