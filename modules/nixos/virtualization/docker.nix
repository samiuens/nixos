{
  config,
  lib,
  ...
}:

let
  cfg = config.smi.virtualization.docker;
in
{
  options.smi.virtualization.docker = {
    enable = lib.mkEnableOption "Docker container runtime";
  };

  config = lib.mkIf cfg.enable {
    virtualisation.docker.enable = true;
  };
}
