{
  lib,
  pkgs,
  userConfig,
  ...
}:

let
  cfg = userConfig.programs.security.gnupg or { };

  inherit (pkgs.stdenv.hostPlatform) isDarwin;

  pinentry = if isDarwin then pkgs.pinentry_mac else pkgs.pinentry-qt;
in
{
  config = lib.mkIf (cfg.enable or false) {
    programs.gpg = {
      enable = true;

      settings = {
        auto-key-locate = "clear";
        no-auto-key-import = true;
        no-auto-key-retrieve = true;
        weak-digest = "SHA1";
      };

      scdaemonSettings.disable-ccid = true;
    };

    services.gpg-agent = {
      enable = true;
      enableScDaemon = true;
      enableSshSupport = false;
      defaultCacheTtl = 300;
      maxCacheTtl = 1800;
      grabKeyboardAndMouse = true;
      noAllowExternalCache = true;
      extraConfig = "no-allow-loopback-pinentry";
      pinentry.package = pinentry;
    };
  };
}
