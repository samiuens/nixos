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
    # netbird-ui from nixpkgs pulls in webkitgtk, which is broken on darwin.
    smi.system.homebrew = {
      extraCasks = [ "netbirdio/tap/netbird-ui" ];
      extraTaps = [ "netbirdio/tap" ];
    };
  };
}
