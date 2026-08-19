# Applications whose nixpkgs derivation is not available on every platform this
# repository targets. Each entry pairs the nixpkgs package with the Homebrew cask
# used as a fallback; `nixUsable` decides which one applies on a given platform,
# so an entry needs no change when nixpkgs gains support for a new system.
#
# Keys are option paths inside a user's `programs`/`services` tree in users/.
pkgs:

{
  "programs.security.yubico-authenticator" = {
    package = pkgs.yubioath-flutter;
    cask = "yubico-authenticator";
  };

  "programs.sync.nextcloud-client" = {
    package = pkgs.nextcloud-client;
    cask = "nextcloud";
  };

  "programs.terminal.ghostty" = {
    package = pkgs.ghostty;
    cask = "ghostty";
  };
}
