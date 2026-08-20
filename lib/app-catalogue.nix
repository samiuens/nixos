# Applications that come from Homebrew rather than nixpkgs on darwin. Each entry
# pairs the nixpkgs package with the Homebrew cask; `preferNixPackage` decides
# which one applies on a given platform, so an entry needs no change when nixpkgs
# gains support for a new system.
#
# Most entries are here because nixpkgs has no darwin build at all. Set
# `preferCask` for the ones where it does build but the cask is wanted anyway;
# the flag is ignored on Linux, where nixpkgs is the only source.
#
# Keys are option paths inside a user's `programs`/`services` tree in users/.
pkgs:

{
  "programs.editor.zed" = {
    package = pkgs.zed-editor;
    cask = "zed";

    # nixpkgs does build this on darwin, but only as a source build that trails
    # the cask by several releases.
    preferCask = true;
  };

  "programs.security.bitwarden" = {
    package = pkgs.bitwarden-desktop;
    cask = "bitwarden";

    # nixpkgs does build this on darwin; the cask is preferred anyway so the app
    # is the signed build Bitwarden ships, installed into /Applications.
    preferCask = true;
  };

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
