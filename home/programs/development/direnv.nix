{ lib, userConfig, ... }:

let
  cfg = userConfig.programs.development.direnv or { };
in
{
  config = lib.mkIf (cfg.enable or false) {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = cfg."nix-direnv".enable or true;
    };
  };
}
