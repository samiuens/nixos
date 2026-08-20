{
  config,
  lib,
  ...
}:

let
  cfg = config.smi.services.netbird;
in
{
  options.smi.services.netbird = {
    enable = lib.mkEnableOption "NetBird service, CLI, and GUI";
  };

  config = lib.mkIf cfg.enable {
    # Unlike NixOS, darwin takes the whole client from Homebrew. nixpkgs lists
    # netbird-ui as building here, but it pulls in webkitgtk, which is broken on
    # darwin, and pairing the cask's app with a nixpkgs daemon would leave the
    # two on different versions.
    smi.system.homebrew = {
      extraCasks = [ "netbirdio/tap/netbird-ui" ];
      extraTaps = [ "netbirdio/tap" ];
    };
  };
}
