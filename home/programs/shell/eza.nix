{ lib, userConfig, ... }:

let
  cfg = userConfig.programs.shell.eza or { };
in
{
  config = lib.mkIf (cfg.enable or false) {
    programs.eza = {
      enable = true;
      enableFishIntegration = true;
      extraOptions = [ "--group-directories-first" ];
      git = true;
      icons = "auto";
    };
  };
}
