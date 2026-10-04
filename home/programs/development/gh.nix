{ lib, userConfig, ... }:

let
  cfg = userConfig.programs.development.gh or { };
in
{
  config = lib.mkIf (cfg.enable or false) {
    programs.gh = {
      enable = true;
      settings.git_protocol = "ssh";
    };
  };
}
