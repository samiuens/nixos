{
  lib,
  config,
  ...
}:

let
  cfg = config.smi.security.sudo;
in
{
  options.smi.security.sudo = {
    enable = lib.mkEnableOption "Touch ID authentication for sudo";

    reattach = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to reattach sudo to the login session, so Touch ID works inside tmux.";
    };

    watchId = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether an Apple Watch may authorise sudo.";
    };
  };

  config = lib.mkIf cfg.enable {
    security.pam.services.sudo_local = {
      touchIdAuth = true;
      watchIdAuth = cfg.watchId;
      inherit (cfg) reattach;
    };
  };
}
