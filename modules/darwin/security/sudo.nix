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
      description = ''
        Whether to reattach sudo to the user's login session before it
        authenticates. Touch ID is tied to that session, so without this it does
        not work from inside tmux or screen, which is where most shells here
        live. Costs a `pam_reattach` line in {file}`/etc/pam.d/sudo_local`.
      '';
    };

    watchId = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether an Apple Watch may authorise sudo as well. Worth having on a
        machine that spends its time docked with the lid shut, where the Touch
        ID sensor cannot be reached.
      '';
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
