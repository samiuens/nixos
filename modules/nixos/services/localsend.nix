{ config, lib, ... }:

let
  cfg = config.smi.services.localsend;
in
{
  options.smi.services.localsend = {
    enable = lib.mkEnableOption "LocalSend";
  };

  config = lib.mkIf cfg.enable {
    programs.localsend.enable = true;
  };
}
