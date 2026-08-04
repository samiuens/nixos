{
  config,
  lib,
  ...
}:

let
  cfg = config.smi.virtualization.podman;
in
{
  options.smi.virtualization.podman = {
    enable = lib.mkEnableOption "Podman container runtime";
  };

  config = lib.mkIf cfg.enable {
    virtualisation.podman.enable = true;
  };
}
