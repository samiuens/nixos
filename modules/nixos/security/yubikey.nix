{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.smi.security.yubikey;
in
{
  options.smi.security.yubikey.enable = lib.mkEnableOption "YubiKey system support";

  config = lib.mkIf cfg.enable {
    services.pcscd.enable = true;
    services.udev.packages = [ pkgs.yubikey-personalization ];
  };
}
