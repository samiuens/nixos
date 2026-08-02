{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.smi.packages.graphify;
  graphify = pkgs.callPackage ../../../packages/graphify/default.nix { };
in
{
  options.smi.packages.graphify = {
    enable = lib.mkEnableOption "Graphify";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ graphify ];
  };
}
