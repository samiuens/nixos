{
  config,
  lib,
  ...
}:

let
  cfg = config.smi.services.tailscale;
in
{
  options.smi.services.tailscale = {
    enable = lib.mkEnableOption "Tailscale service, CLI, and GUI";
  };

  config = lib.mkIf cfg.enable {
    # Unlike NixOS, darwin takes the whole client from Homebrew. The standalone
    # app bundles its own system extension and menu bar GUI, which the nixpkgs
    # daemon has no counterpart for.
    smi.system.homebrew.extraCasks = [ "tailscale-app" ];
  };
}
