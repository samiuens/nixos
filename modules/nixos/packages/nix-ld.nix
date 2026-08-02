{ config, lib, ... }:

let
  cfg = config.smi.packages.nix-ld;
in
{
  options.smi.packages.nix-ld = {
    enable = lib.mkEnableOption "nix-ld";
  };

  config = lib.mkIf cfg.enable {
    programs.nix-ld.enable = true;
  };
}
