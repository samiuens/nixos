{ lib, userConfig, ... }:

let
  cfg = userConfig.programs.development.bun or { };
in
{
  config = lib.mkIf (cfg.enable or false) {
    programs.bun.enable = true;
  };
}
