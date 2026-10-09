{ config, lib, ... }:

let
  cfg = config.smi.services.kdeconnect;
in
{
  options.smi.services.kdeconnect = {
    enable = lib.mkEnableOption "KDE Connect";
  };

  config = lib.mkIf cfg.enable {
    programs.kdeconnect.enable = true;
  };
}
